//
//  NodeExpansionManager.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/23/26.
//
import SwiftUI

@MainActor
class NodeExpansionManager {
    private let profileManager: UserProfileManager
    private let categoryHierarchy: [CategoryNode]
    
    init(profileManager: UserProfileManager, categoryHierarchy: [CategoryNode]) {
        self.profileManager = profileManager
        self.categoryHierarchy = categoryHierarchy
    }
    
    func expandNode(
        _ node: Node,
        nodes: [Node],
        nodeMetadata: [UUID: NodeMetadata]
    ) -> ExpansionResult? {
        let spawnRadius: CGFloat = node.type == .me ? 160 : 80
        
        var childLabels: [String] = []
        var childType: Node.NodeType = .datapoint
        
        switch node.type {
        case .me:
            childLabels = limitToFive(categoryHierarchy.map { $0.name })
            childType = .category
            
        case .category:
            if let category = categoryHierarchy.first(where: { $0.name == node.label }) {
                childLabels = limitToFive(category.subcategories.map { $0.name })
                childType = .subcategory
            }
            
        case .subcategory:
            if let metadata = nodeMetadata[node.id],
               let categoryName = metadata.category,
               let category = categoryHierarchy.first(where: { $0.name == categoryName }),
               let subcategory = category.subcategories.first(where: { $0.name == node.label }) {
                
                if !subcategory.subSubcategories.isEmpty {
                    childLabels = limitToFive(subcategory.subSubcategories.map { $0.name })
                    childType = .subSubcategory
                } else {
                    childLabels = selectItemsToShow(
                        items: subcategory.items,
                        category: categoryName,
                        subcategory: node.label,
                        subSubcategory: nil
                    )
                    childType = .datapoint
                }
            }
            
        case .subSubcategory:
            if let metadata = nodeMetadata[node.id],
               let categoryName = metadata.category,
               let subcategoryName = metadata.subcategory,
               let category = categoryHierarchy.first(where: { $0.name == categoryName }),
               let subcategory = category.subcategories.first(where: { $0.name == subcategoryName }),
               let subSubcategory = subcategory.subSubcategories.first(where: { $0.name == node.label }) {
                
                childLabels = selectItemsToShow(
                    items: subSubcategory.items,
                    category: categoryName,
                    subcategory: subcategoryName,
                    subSubcategory: node.label
                )
                childType = .datapoint
            }
            
        case .datapoint:
            return nil
        }
        
        guard !childLabels.isEmpty else { return nil }
        
        let inheritedColor = node.type == .category ? node.color : node.categoryColor
        
        return ExpansionResult(
            labels: childLabels,
            type: childType,
            spawnRadius: spawnRadius,
            inheritedColor: inheritedColor
        )
    }
    
    func createChildNodes(
        labels: [String],
        type: Node.NodeType,
        parentNode: Node,
        parentPosition: CGPoint,
        spawnRadius: CGFloat,
        inheritedColor: Color?,
        nodeMetadata: [UUID: NodeMetadata]
    ) -> NodeCreationResult {
        let angleStep = (2 * CGFloat.pi) / CGFloat(labels.count)
        var newNodes: [Node] = []
        var newEdges: [Edge] = []
        var newMetadata: [UUID: NodeMetadata] = [:]
        
        for (i, label) in labels.enumerated() {
            let angle = angleStep * CGFloat(i) - CGFloat.pi / 2
            let spawnX = parentPosition.x + spawnRadius * cos(angle)
            let spawnY = parentPosition.y + spawnRadius * sin(angle)
            
            let metadata = buildMetadata(
                for: type,
                label: label,
                parentNode: parentNode,
                nodeMetadata: nodeMetadata,
                inheritedColor: inheritedColor
            )
            
            let isSaved = type == .datapoint && profileManager.isDatapointSaved(
                profileManager.datapointPath(
                    category: metadata.category,
                    subcategory: metadata.subcategory,
                    subSubcategory: metadata.subSubcategory,
                    label: label
                )
            )
            
            let savedCount = type != .datapoint ? countSavedDatapoints(
                category: metadata.category,
                subcategory: metadata.subcategory,
                subSubcategory: metadata.subSubcategory
            ) : 0
            
            let formattedLabel = type == .datapoint ? label.replacingOccurrences(of: "_", with: "/") : label
            
            let childNode = Node(
                position: CGPoint(x: spawnX, y: spawnY),
                label: formattedLabel,
                type: type,
                isSavedToProfile: isSaved,
                parentId: parentNode.id,
                categoryColor: inheritedColor,
                textWidth: calculateTextWidth(for: formattedLabel, nodeType: type, savedCount: savedCount),
                savedCount: savedCount
            )
            
            newMetadata[childNode.id] = NodeMetadata(
                type: type,
                category: metadata.category,
                subcategory: metadata.subcategory,
                subSubcategory: metadata.subSubcategory,
                categoryColor: inheritedColor
            )
            
            newNodes.append(childNode)
            
            let edge = Edge(
                fromId: parentNode.id,
                toId: childNode.id,
                thickness: 2.5
            )
            newEdges.append(edge)
        }
        
        return NodeCreationResult(
            nodes: newNodes,
            edges: newEdges,
            metadata: newMetadata
        )
    }
    
    func updateSavedCounts(
        nodes: inout [Node],
        nodeMetadata: [UUID: NodeMetadata]
    ) {
        for i in nodes.indices {
            let node = nodes[i]
            guard node.type != .datapoint else { continue }
            
            if let metadata = nodeMetadata[node.id] {
                let count = countSavedDatapoints(
                    category: metadata.category,
                    subcategory: metadata.subcategory,
                    subSubcategory: metadata.subSubcategory
                )
                nodes[i].savedCount = count
                nodes[i].textWidth = calculateTextWidth(
                    for: node.label,
                    nodeType: node.type,
                    savedCount: count
                )
            }
        }
    }
    
    private func limitToFive(_ items: [String]) -> [String] {
        guard items.count > 5 else { return items }
        return Array(items.shuffled().prefix(5))
    }
    
    private func selectItemsToShow(
        items: [String],
        category: String,
        subcategory: String,
        subSubcategory: String?
    ) -> [String] {
        var itemsToShow: [String] = []
        
        for item in items {
            let path = profileManager.datapointPath(
                category: category,
                subcategory: subcategory,
                subSubcategory: subSubcategory,
                label: item
            )
            if profileManager.isDatapointSaved(path) {
                itemsToShow.append(item)
            }
        }
        
        let remainingCount = max(0, 5 - itemsToShow.count)
        let unsavedItems = items.filter { !itemsToShow.contains($0) }
        itemsToShow.append(contentsOf: Array(unsavedItems.shuffled().prefix(remainingCount)))
        
        return itemsToShow
    }
    
    private func buildMetadata(
        for type: Node.NodeType,
        label: String,
        parentNode: Node,
        nodeMetadata: [UUID: NodeMetadata],
        inheritedColor: Color?
    ) -> (category: String?, subcategory: String?, subSubcategory: String?) {
        var category: String? = nil
        var subcategory: String? = nil
        var subSubcategory: String? = nil
        
        if type == .category {
            category = label
        } else if type == .subcategory {
            if let parentMetadata = nodeMetadata[parentNode.id] {
                category = parentMetadata.category
            }
            subcategory = label
        } else if type == .subSubcategory {
            if let parentMetadata = nodeMetadata[parentNode.id] {
                category = parentMetadata.category
                subcategory = parentMetadata.subcategory
            }
            subSubcategory = label
        } else if type == .datapoint {
            if let parentMetadata = nodeMetadata[parentNode.id] {
                category = parentMetadata.category
                subcategory = parentMetadata.subcategory
                subSubcategory = parentMetadata.subSubcategory
            }
        }
        
        return (category, subcategory, subSubcategory)
    }
    
    private func calculateTextWidth(for label: String, nodeType: Node.NodeType, savedCount: Int = 0) -> CGFloat {
        let fontSize: CGFloat = nodeType == .me ? 16 : 14
        let font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        
        var fullText = label
        if savedCount > 0 && nodeType != .datapoint {
            fullText += " (\(savedCount))"
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (fullText as NSString).size(withAttributes: attributes)
        
        return size.width
    }
    
    private func countSavedDatapoints(
        category: String?,
        subcategory: String?,
        subSubcategory: String?
    ) -> Int {
        var count = 0
        
        guard let categoryName = category,
              let categoryNode = categoryHierarchy.first(where: { $0.name == categoryName }) else {
            return 0
        }
        
        if let subcategoryName = subcategory {
            guard let subcategoryNode = categoryNode.subcategories.first(where: { $0.name == subcategoryName }) else {
                return 0
            }
            
            if let subSubcategoryName = subSubcategory {
                guard let subSubcategoryNode = subcategoryNode.subSubcategories.first(where: { $0.name == subSubcategoryName }) else {
                    return 0
                }
                
                for item in subSubcategoryNode.items {
                    let path = profileManager.datapointPath(
                        category: categoryName,
                        subcategory: subcategoryName,
                        subSubcategory: subSubcategoryName,
                        label: item
                    )
                    if profileManager.isDatapointSaved(path) {
                        count += 1
                    }
                }
            } else {
                for item in subcategoryNode.items {
                    let path = profileManager.datapointPath(
                        category: categoryName,
                        subcategory: subcategoryName,
                        subSubcategory: nil,
                        label: item
                    )
                    if profileManager.isDatapointSaved(path) {
                        count += 1
                    }
                }
                
                for subSubcat in subcategoryNode.subSubcategories {
                    for item in subSubcat.items {
                        let path = profileManager.datapointPath(
                            category: categoryName,
                            subcategory: subcategoryName,
                            subSubcategory: subSubcat.name,
                            label: item
                        )
                        if profileManager.isDatapointSaved(path) {
                            count += 1
                        }
                    }
                }
            }
        } else {
            for subcat in categoryNode.subcategories {
                for item in subcat.items {
                    let path = profileManager.datapointPath(
                        category: categoryName,
                        subcategory: subcat.name,
                        subSubcategory: nil,
                        label: item
                    )
                    if profileManager.isDatapointSaved(path) {
                        count += 1
                    }
                }
                
                for subSubcat in subcat.subSubcategories {
                    for item in subSubcat.items {
                        let path = profileManager.datapointPath(
                            category: categoryName,
                            subcategory: subcat.name,
                            subSubcategory: subSubcat.name,
                            label: item
                        )
                        if profileManager.isDatapointSaved(path) {
                            count += 1
                        }
                    }
                }
            }
        }
        
        return count
    }
}

struct ExpansionResult {
    let labels: [String]
    let type: Node.NodeType
    let spawnRadius: CGFloat
    let inheritedColor: Color?
}

struct NodeCreationResult {
    let nodes: [Node]
    let edges: [Edge]
    let metadata: [UUID: NodeMetadata]
}
