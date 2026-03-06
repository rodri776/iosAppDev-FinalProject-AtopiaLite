//
//  PhysicsEngine.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/16/26.
//

import CoreGraphics
import Foundation

@MainActor
class PhysicsEngine {
    
    private let repulsionStrength: CGFloat = 50000
    private let collisionCorrectionRate: CGFloat = 0.4
    private let damping: CGFloat = 0.96
    private let centerPullStrength: CGFloat = 0.0005
    private var canvasSize: CGSize = .zero
    
    init(canvasSize: CGSize = .zero) {
        self.canvasSize = canvasSize
    }
    
    func setCanvasSize(_ size: CGSize) {
        canvasSize = size
    }
    
    func updatePhysics(nodes: inout [Node]) {
        guard !nodes.isEmpty else { return }
        
        let dt: CGFloat = 1.0 / 60.0
        
        for i in nodes.indices {
            var force = CGVector.zero
            let nodeA = nodes[i]
            let radiusA = nodeRadius(for: nodeA.type)
            
            if !nodeA.childIds.isEmpty {
                continue
            }
            
            for j in nodes.indices where i != j {
                let nodeB = nodes[j]
                let radiusB = nodeRadius(for: nodeB.type)
                
                let dx = nodeA.position.x - nodeB.position.x
                let dy = nodeA.position.y - nodeB.position.y
                let distSq = max(dx * dx + dy * dy, 1)
                let dist = sqrt(distSq)
                
                let minDist = radiusA + radiusB + 70
                
                let areSiblings = nodeA.parentId == nodeB.parentId && nodeA.parentId != nil
                let isParent = nodeA.parentId == nodeB.id
                
                // Collision — push overlapping nodes apart
                if dist < minDist {
                    let overlap = minDist - dist
                    let correction = isParent ? overlap * 0.6 : overlap * collisionCorrectionRate
                    
                    nodes[i].position.x += (dx / dist) * correction
                    nodes[i].position.y += (dy / dist) * correction
                    
                    // Kill velocity toward the collision
                    let dotProduct = nodes[i].velocity.dx * (dx / dist) + nodes[i].velocity.dy * (dy / dist)
                    if dotProduct < 0 {
                        nodes[i].velocity.dx -= (dx / dist) * dotProduct
                        nodes[i].velocity.dy -= (dy / dist) * dotProduct
                    }
                    
                    let dampingFactor = isParent ? 0.4 : 0.6
                    nodes[i].velocity.dx *= dampingFactor
                    nodes[i].velocity.dy *= dampingFactor
                }
                
                if areSiblings {
                    let clusterRange: CGFloat = 220
                    if dist > minDist && dist < clusterRange {
                        let attraction = -12.0
                        force.dx += (dx / dist) * attraction
                        force.dy += (dy / dist) * attraction
                    }
                    
                    if dist < minDist * 2.5 {
                        let repulsion = repulsionStrength * 0.3 / distSq
                        force.dx += (dx / dist) * repulsion
                        force.dy += (dy / dist) * repulsion
                    }
                } else if !isParent {
                    if dist < minDist * 5 {
                        let groupRepulsion: CGFloat = 2.5
                        let repulsion = (repulsionStrength * groupRepulsion) / distSq
                        force.dx += (dx / dist) * repulsion
                        force.dy += (dy / dist) * repulsion
                    }
                }
            }
            
            // Spring toward parent
            if let parentId = nodeA.parentId,
               let parent = nodes.first(where: { $0.id == parentId }) {
                let dx = parent.position.x - nodeA.position.x
                let dy = parent.position.y - nodeA.position.y
                let dist = sqrt(dx * dx + dy * dy)
                
                if dist > 0 {
                    let idealDistance: CGFloat = 140
                    let displacement = dist - idealDistance
                    let parentSpringStrength: CGFloat = 0.06
                    let springForce = displacement * parentSpringStrength
                    
                    force.dx += (dx / dist) * springForce
                    force.dy += (dy / dist) * springForce
                }
            } else {
                // Gentle center gravity for root nodes
                let centerX = canvasSize.width / 2
                let centerY = canvasSize.height / 2
                let dx = centerX - nodeA.position.x
                let dy = centerY - nodeA.position.y
                let distToCenter = sqrt(dx * dx + dy * dy)
                
                if distToCenter > 100 {
                    force.dx += dx * centerPullStrength
                    force.dy += dy * centerPullStrength
                }
            }
            
            nodes[i].velocity.dx += force.dx * dt
            nodes[i].velocity.dy += force.dy * dt
            
            nodes[i].velocity.dx *= damping
            nodes[i].velocity.dy *= damping
            
            let maxVelocity: CGFloat = 600
            let speed = sqrt(nodes[i].velocity.dx * nodes[i].velocity.dx + nodes[i].velocity.dy * nodes[i].velocity.dy)
            if speed > maxVelocity {
                let scale = maxVelocity / speed
                nodes[i].velocity.dx *= scale
                nodes[i].velocity.dy *= scale
            }
            
            let minVelocity: CGFloat = 2.0
            if speed < minVelocity {
                nodes[i].velocity.dx = 0
                nodes[i].velocity.dy = 0
            }
            
            nodes[i].position.x += nodes[i].velocity.dx * dt
            nodes[i].position.y += nodes[i].velocity.dy * dt
            
            // Soft bounce off edges
            let margin = radiusA + 20
            if nodes[i].position.x < margin {
                nodes[i].position.x = margin
                nodes[i].velocity.dx = abs(nodes[i].velocity.dx) * 0.3
            }
            if nodes[i].position.x > canvasSize.width - margin {
                nodes[i].position.x = canvasSize.width - margin
                nodes[i].velocity.dx = -abs(nodes[i].velocity.dx) * 0.3
            }
            if nodes[i].position.y < margin {
                nodes[i].position.y = margin
                nodes[i].velocity.dy = abs(nodes[i].velocity.dy) * 0.3
            }
            if nodes[i].position.y > canvasSize.height - margin {
                nodes[i].position.y = canvasSize.height - margin
                nodes[i].velocity.dy = -abs(nodes[i].velocity.dy) * 0.3
            }
        }
    }
    
    func nodeRadius(for type: Node.NodeType) -> CGFloat {
        switch type {
        case .me: return 25
        case .category: return 40
        case .subcategory: return 35
        case .subSubcategory: return 30
        case .datapoint: return 25
        }
    }
}
