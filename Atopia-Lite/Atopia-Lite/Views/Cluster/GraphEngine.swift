//
//  GraphEngine.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/23/26.
//

import SwiftUI

@MainActor
class GraphEngine {
    private let physicsEngine: PhysicsEngine
    private var canvasSize: CGSize = .zero
    
    init(physicsEngine: PhysicsEngine) {
        self.physicsEngine = physicsEngine
    }
    
    func setCanvasSize(_ size: CGSize) {
        canvasSize = size
        physicsEngine.setCanvasSize(size)
    }
    
    // MARK: - Physics Updates
    
    func updatePhysics(nodes: inout [Node]) {
        physicsEngine.updatePhysics(nodes: &nodes)
    }
    
    // MARK: - Group Backgrounds
    
    func calculateGroupBackgrounds(for nodes: [Node]) -> [GroupBackground] {
        var backgrounds: [GroupBackground] = []
        
        // Find all parent nodes with expanded children
        let parentsWithChildren = nodes.filter { !$0.childIds.isEmpty && $0.isExpanded }
        
        for parent in parentsWithChildren {
            let children = nodes.filter { parent.childIds.contains($0.id) }
            guard children.count > 1 else { continue }
            
            let positions = children.map { $0.position }
            let centerX = positions.reduce(0.0) { $0 + $1.x } / CGFloat(positions.count)
            let centerY = positions.reduce(0.0) { $0 + $1.y } / CGFloat(positions.count)
            let center = CGPoint(x: centerX, y: centerY)
            
            var maxDistance: CGFloat = 0
            for pos in positions {
                let dist = sqrt(pow(pos.x - centerX, 2) + pow(pos.y - centerY, 2))
                maxDistance = max(maxDistance, dist)
            }
            
            let padding: CGFloat = 80
            let radius = maxDistance + padding
            
            backgrounds.append(GroupBackground(center: center, radius: radius, color: parent.color))
        }
        
        return backgrounds
    }
    
    // MARK: - Zoom & Pan
    
    func calculateZoomAndPan(
        for nodes: [Node],
        currentZoom: CGFloat,
        currentPan: CGSize
    ) -> (zoom: CGFloat, pan: CGSize) {
        guard !nodes.isEmpty else { return (currentZoom, currentPan) }
        
        var minX = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var minY = CGFloat.infinity
        var maxY = -CGFloat.infinity
        
        for node in nodes {
            let radius = physicsEngine.nodeRadius(for: node.type)
            minX = min(minX, node.position.x - radius)
            maxX = max(maxX, node.position.x + radius)
            minY = min(minY, node.position.y - radius)
            maxY = max(maxY, node.position.y + radius)
        }
        
        let graphWidth = maxX - minX + 100
        let graphHeight = maxY - minY + 100
        
        let scaleX = canvasSize.width / graphWidth
        let scaleY = canvasSize.height / graphHeight
        let targetScale = min(scaleX, scaleY, 1.0)
        
        let zoomSpeed: CGFloat = 0.05
        let newZoom = currentZoom + (targetScale - currentZoom) * zoomSpeed
        
        let graphCenterX = (minX + maxX) / 2
        let graphCenterY = (minY + maxY) / 2
        let canvasCenterX = canvasSize.width / 2
        let canvasCenterY = canvasSize.height / 2
        
        let targetPanX = (canvasCenterX - graphCenterX * newZoom)
        let targetPanY = (canvasCenterY - graphCenterY * newZoom)
        
        let newPanWidth = currentPan.width + (targetPanX - currentPan.width) * zoomSpeed
        let newPanHeight = currentPan.height + (targetPanY - currentPan.height) * zoomSpeed
        
        return (newZoom, CGSize(width: newPanWidth, height: newPanHeight))
    }
    
    // MARK: - Node Expansion/Collapse
    
    func collapseNode(
        nodeId: UUID,
        nodes: inout [Node],
        edges: inout [Edge]
    ) {
        guard let nodeIndex = nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        let childIds = nodes[nodeIndex].childIds
        
        // Recursively collapse children
        for childId in childIds {
            if let childIndex = nodes.firstIndex(where: { $0.id == childId }),
               nodes[childIndex].isExpanded {
                collapseNode(nodeId: childId, nodes: &nodes, edges: &edges)
            }
        }
        
        // Remove edges connected to these children
        edges.removeAll { edge in
            childIds.contains(edge.fromId) || childIds.contains(edge.toId)
        }
        
        // Remove child nodes
        nodes.removeAll { childIds.contains($0.id) }
        
        // Clear parent's childIds and expanded state
        nodes[nodeIndex].childIds = []
        nodes[nodeIndex].isExpanded = false
    }
    
    // MARK: - Active Path
    
    func calculateActivePath(nodes: [Node]) -> [UUID] {
        var activePath: [UUID] = []
        
        guard let meNode = nodes.first(where: { $0.type == .me }) else { return [] }
        activePath.append(meNode.id)
        
        var currentNode = meNode
        while currentNode.isExpanded && !currentNode.childIds.isEmpty {
            if let expandedChild = nodes.first(where: {
                currentNode.childIds.contains($0.id) && $0.isExpanded
            }) {
                activePath.append(expandedChild.id)
                currentNode = expandedChild
            } else {
                activePath.append(contentsOf: currentNode.childIds)
                break
            }
        }
        
        return activePath
    }
    
    // MARK: - Reparenting (For Recommendation Nodes)
    
    func reparentNode(
        nodeId: UUID,
        newParentId: UUID,
        nodes: inout [Node],
        edges: inout [Edge],
        nodeMetadata: [UUID: NodeMetadata]
    ) {
        guard let nodeIndex = nodes.firstIndex(where: { $0.id == nodeId }),
              let newParentIndex = nodes.firstIndex(where: { $0.id == newParentId }) else {
            return
        }
        
        // removes old parent relationship
        if let oldParentId = nodes[nodeIndex].parentId {
            if let oldParentIndex = nodes.firstIndex(where: { $0.id == oldParentId }) {
                nodes[oldParentIndex].childIds.removeAll { $0 == nodeId }
            }
            edges.removeAll { $0.fromId == oldParentId && $0.toId == nodeId }
        }
        
        // sets new parent
        nodes[nodeIndex].parentId = newParentId
        
        // adds to new parent's children
        if !nodes[newParentIndex].childIds.contains(nodeId) {
            nodes[newParentIndex].childIds.append(nodeId)
        }
        
        // creates new edge
        let newEdge = Edge(
            fromId: newParentId,
            toId: nodeId,
            thickness: 1.5
        )
        edges.append(newEdge)
    }
    
    func shouldReparent(
        node: Node,
        nodeMetadata: NodeMetadata,
        newParent: Node,
        newParentMetadata: NodeMetadata,
        nodes: [Node],
        allMetadata: [UUID: NodeMetadata]
    ) -> Bool {
        guard node.type == .datapoint else { return false }
        guard node.parentId != newParent.id else { return false }
        
        let matchesHierarchy: Bool
        
        switch newParent.type {
        case .subSubcategory:
            matchesHierarchy = nodeMetadata.category == newParentMetadata.category &&
                              nodeMetadata.subcategory == newParentMetadata.subcategory &&
                              nodeMetadata.subSubcategory == newParentMetadata.subSubcategory
            
        case .subcategory:
            matchesHierarchy = nodeMetadata.category == newParentMetadata.category &&
                              nodeMetadata.subcategory == newParentMetadata.subcategory &&
                              (nodeMetadata.subSubcategory == nil ||
                               !nodeExists(
                                type: .subSubcategory,
                                label: nodeMetadata.subSubcategory!,
                                category: nodeMetadata.category,
                                subcategory: nodeMetadata.subcategory,
                                nodes: nodes,
                                metadata: allMetadata
                               ))
            
        case .category:
            matchesHierarchy = nodeMetadata.category == newParentMetadata.category &&
                              !nodeExists(
                                type: .subcategory,
                                label: nodeMetadata.subcategory!,
                                category: nodeMetadata.category,
                                subcategory: nil,
                                nodes: nodes,
                                metadata: allMetadata
                              )
            
        default:
            matchesHierarchy = false
        }
        
        guard matchesHierarchy else { return false }
        
        // Check if current parent is already correct
        if let currentParentId = node.parentId,
           let currentParent = nodes.first(where: { $0.id == currentParentId }),
           let currentParentMetadata = allMetadata[currentParentId] {
            return !isParentCorrect(
                node: node,
                nodeMetadata: nodeMetadata,
                parent: currentParent,
                parentMetadata: currentParentMetadata,
                nodes: nodes,
                allMetadata: allMetadata
            )
        }
        
        return true
    }
    
    private func isParentCorrect(
        node: Node,
        nodeMetadata: NodeMetadata,
        parent: Node,
        parentMetadata: NodeMetadata,
        nodes: [Node],
        allMetadata: [UUID: NodeMetadata]
    ) -> Bool {
        switch parent.type {
        case .subSubcategory:
            return parentMetadata.category == nodeMetadata.category &&
                   parentMetadata.subcategory == nodeMetadata.subcategory &&
                   parentMetadata.subSubcategory == nodeMetadata.subSubcategory
            
        case .subcategory:
            return parentMetadata.category == nodeMetadata.category &&
                   parentMetadata.subcategory == nodeMetadata.subcategory &&
                   nodeMetadata.subSubcategory == nil
            
        case .category:
            return parentMetadata.category == nodeMetadata.category &&
                   !nodeExists(
                    type: .subcategory,
                    label: nodeMetadata.subcategory!,
                    category: nodeMetadata.category,
                    subcategory: nil,
                    nodes: nodes,
                    metadata: allMetadata
                   )
            
        default:
            return false
        }
    }
    
    private func nodeExists(
        type: Node.NodeType,
        label: String,
        category: String?,
        subcategory: String?,
        nodes: [Node],
        metadata: [UUID: NodeMetadata]
    ) -> Bool {
        return nodes.contains { node in
            guard node.type == type && node.label == label else { return false }
            guard let meta = metadata[node.id] else { return false }
            
            if let category = category {
                guard meta.category == category else { return false }
            }
            
            if let subcategory = subcategory {
                guard meta.subcategory == subcategory else { return false }
            }
            
            return true
        }
    }
}
