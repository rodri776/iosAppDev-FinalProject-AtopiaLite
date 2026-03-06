//
//  Models.swift
//  TheCluster
//
//  Created by Juniper Rodriguez on 2/16/26.
//

import SwiftUI

enum NodeFocusState {
    case normal
    case highlighted
    case dimmed
}

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
    var parentId: UUID? = nil
    var childIds: [UUID] = []
    var categoryColor: Color? = nil
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

struct Edge: Identifiable {
    let id = UUID()
    let fromId: UUID
    let toId: UUID
    var thickness: CGFloat
}

struct GroupBackground: Identifiable {
    let id = UUID()
    var center: CGPoint
    var radius: CGFloat
    var color: Color
}

struct DataItem: Codable {
    let id: String
    let label: String
    let category: String
    let subcategory: String
    let sub_subcategory: String?
    let tags: [String]
}

struct CategoryNode {
    let name: String
    var subcategories: [SubcategoryNode] = []
}

struct SubcategoryNode {
    let name: String
    var subSubcategories: [SubSubcategoryNode] = []
    var items: [String] = []
}

struct SubSubcategoryNode {
    let name: String
    var items: [String] = []
}

struct NodeMetadata {
    let type: Node.NodeType
    let category: String?
    let subcategory: String?
    let subSubcategory: String?
    let categoryColor: Color?
}

struct SavedDatapoint: Identifiable {
    let id = UUID()
    let label: String
    let category: String
    let subcategory: String
    let subSubcategory: String?
    let categoryColor: Color
}

struct SavedCategory: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let datapoints: [SavedDatapoint]
}
