//
//  RecommendationDisplayManager.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/23/26.
//

import SwiftUI

@MainActor
class RecommendationDisplayManager {
    
    func createRecommendationNodes(
        recommendations: [ClusterRecommendation],
        nodes: [Node],
        nodeMetadata: [UUID: NodeMetadata]
    ) -> NodeCreationResult {
        var allNewNodes: [Node] = []
        var allNewEdges: [Edge] = []
        var allNewMetadata: [UUID: NodeMetadata] = [:]
        
        var recommendationsByParent: [String: [ClusterRecommendation]] = [:]
        for rec in recommendations {
            var key = "\(rec.category)/\(rec.subcategory)"
            if let subSub = rec.subSubcategory {
                key += "/\(subSub)"
            }
            recommendationsByParent[key, default: []].append(rec)
        }
        
        for (_, recs) in recommendationsByParent {
            guard let firstRec = recs.first else { continue }
            let parentNode = findParentNode(for: firstRec, in: nodes, nodeMetadata: nodeMetadata)
            
            let radius: CGFloat = 120
            let angleStep = (2 * CGFloat.pi) / CGFloat(recs.count)
            
            for (index, rec) in recs.enumerated() {
                let angle = angleStep * CGFloat(index) - CGFloat.pi / 2
                let spawnX = parentNode.position.x + radius * cos(angle)
                let spawnY = parentNode.position.y + radius * sin(angle)
                
                let tempNode = Node(position: .zero, label: rec.category, type: .category)
                let categoryColor = tempNode.color
                
                let formattedLabel = rec.label.replacingOccurrences(of: "_", with: "/")
                let textWidth = calculateTextWidth(for: formattedLabel)
                
                let node = Node(
                    position: CGPoint(x: spawnX, y: spawnY),
                    label: formattedLabel,
                    type: .datapoint,
                    isRecommended: true,
                    isFromRecommendation: true,
                    parentId: parentNode.id,
                    categoryColor: categoryColor,
                    textWidth: textWidth
                )
                
                allNewNodes.append(node)
                allNewEdges.append(Edge(fromId: parentNode.id, toId: node.id, thickness: 2.0))
                
                allNewMetadata[node.id] = NodeMetadata(
                    type: .datapoint,
                    category: rec.category,
                    subcategory: rec.subcategory,
                    subSubcategory: rec.subSubcategory,
                    categoryColor: categoryColor
                )
            }
        }
        
        return NodeCreationResult(nodes: allNewNodes, edges: allNewEdges, metadata: allNewMetadata)
    }
    
    private func findParentNode(
        for recommendation: ClusterRecommendation,
        in nodes: [Node],
        nodeMetadata: [UUID: NodeMetadata]
    ) -> Node {
        if let subSub = recommendation.subSubcategory {
            if let node = nodes.first(where: {
                $0.type == .subSubcategory &&
                $0.label == subSub &&
                nodeMetadata[$0.id]?.category == recommendation.category &&
                nodeMetadata[$0.id]?.subcategory == recommendation.subcategory
            }) {
                return node
            }
        }
        
        if let node = nodes.first(where: {
            $0.type == .subcategory &&
            $0.label == recommendation.subcategory &&
            nodeMetadata[$0.id]?.category == recommendation.category
        }) {
            return node
        }
        
        if let node = nodes.first(where: {
            $0.type == .category &&
            $0.label == recommendation.category
        }) {
            return node
        }
        
        return nodes.first(where: { $0.type == .me }) ?? nodes[0]
    }
    
    private func calculateTextWidth(for label: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return (label as NSString).size(withAttributes: attributes).width
    }
}
