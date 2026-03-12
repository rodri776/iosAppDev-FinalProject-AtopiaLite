//
//  Models.swift
//  TheCluster
//
//  Created by Juniper Rodriguez on 2/16/26.
//

import SwiftUI

/// Tracks whether a node is visually focused, highlighted, or faded out.
enum NodeFocusState {
    case normal
    case highlighted
    case dimmed
}

/// A single node in the interest graph (category, subcategory, or datapoint).
struct Node: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector = .zero
    var label: String
    var type: NodeType
    var isExpanded: Bool = false
    var isSavedToProfile: Bool = false
    var isRecommended: Bool = false
    var isFromRecommendation: Bool = false
    var parentId: UUID?
    var childIds: [UUID] = []
    var categoryColor: Color?
    var textWidth: CGFloat = 0
    var savedCount: Int = 0
    
    enum NodeType: Equatable, Hashable {
        case me
        case category
        case subcategory
        case subSubcategory
        case datapoint
    }
    
    var color: Color {
        switch type {
        case .me:
            return Color("RecPurple1")
        case .category:
            switch label {
            case "Fitness":   return Color("FitnessBlue")
            case "Hobbies":   return Color("HobbiesRed")
            case "Ideas":     return Color("IdeasGold")
            case "Media":     return Color("MediaOrange")
            default:          return Color("SavedGreen")
            }
        case .subcategory, .subSubcategory:
            return categoryColor ?? Color("RecPurple1")
        case .datapoint:
            if isSavedToProfile {
                return (categoryColor ?? Color.white).opacity(0.7)
            } else {
                return Color.gray
            }
        }
    }
}

/// A line connecting two nodes in the graph.
struct Edge: Identifiable {
    let id = UUID()
    let fromId: UUID
    let toId: UUID
    var thickness: CGFloat
}

/// Translucent circle drawn behind a cluster of related nodes.
struct GroupBackground: Identifiable {
    let id = UUID()
    var center: CGPoint
    var radius: CGFloat
    var color: Color
}

/// One entry from the bundled JSON dataset.
struct DataItem: Codable {
    let id: String
    let label: String
    let category: String
    let subcategory: String?
    let sub_subcategory: String?
    let tags: [String]
}

/// Hierarchy node used when building the graph from the dataset.
struct CategoryNode {
    let name: String
    var subcategories: [SubcategoryNode] = []
}

/// Second-level hierarchy node under a category.
struct SubcategoryNode {
    let name: String
    var subSubcategories: [SubSubcategoryNode] = []
    var items: [String] = []
}

/// Third-level hierarchy node under a subcategory.
struct SubSubcategoryNode {
    let name: String
    var items: [String] = []
}

/// Stores the category path and type for a node, used to look up ancestry.
struct NodeMetadata {
    let type: Node.NodeType
    let category: String?
    let subcategory: String?
    let subSubcategory: String?
    let categoryColor: Color?
}

/// A datapoint the user has saved, with its full category path.
struct SavedDatapoint: Identifiable {
    let id = UUID()
    let label: String
    let category: String
    let subcategory: String
    let subSubcategory: String?
    let categoryColor: Color
}

/// Groups saved datapoints under their parent category for display.
struct SavedCategory: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let datapoints: [SavedDatapoint]
}
