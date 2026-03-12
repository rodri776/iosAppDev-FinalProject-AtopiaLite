//
//  InstructionState.swift
//  TheCluster
//
//  Created by Juniper Rodriguez on 2/26/26.
//
import Foundation

/// The hint text shown below the graph as the user navigates nodes.
enum InstructionState {
    case idle
    case exploringCategory
    case exploringSubcategory
    case exploringSubSubcategory
    case selectingDatapoint
    case datapointAdded
    case recommendationAdded
    case datapointRemoved
    case recommendationMode
    case recommendationsDismissed
    case collapseMode
    case error(String)
    
    var text: String {
        switch self {
        case .idle:
            return "Press \"Me\" to begin interactive onboarding."
        case .exploringCategory:
            return "Select category to explore datapoints. 🔍"
        case .exploringSubcategory:
            return "Select subcategory to explore datapoints. 🔍🔍"
        case .exploringSubSubcategory:
            return "Select sub-subcategory to explore datapoints. 🔍🔍🔍"
        case .selectingDatapoint:
            return "Select datapoint to add to profile ➕ \nor re-tap parent node to randomize new ones to add! 🎲"
        case .datapointAdded:
            return "Added to your profile! ✅ \ntap to remove from profile ❌"
        case .recommendationAdded:
            return "✨ Recommended datapoint added! ✨"
        case .datapointRemoved:
            return "Removed from your profile. 🗑️"
        case .recommendationMode:
            return "✨ AI Recommendations: Tap to save to your profile! ✨"
        case .recommendationsDismissed:
            return "Recommendations dismissed. 💨"
        case .collapseMode:
            return "Tap open nodes to collapse. ➡️⬅️"
        case .error(let message):
            return message
        }
    }
    
    var autoResetDelay: TimeInterval? {
        switch self {
        case .datapointAdded, .recommendationAdded, .datapointRemoved, .collapseMode, .recommendationsDismissed:
            return 2.0
        case .recommendationMode:
            return 5.0
        case .error:
            return 3.0
        default:
            return nil
        }
    }
    
    func defaultState(for childType: Node.NodeType?) -> InstructionState {
        guard let childType = childType else {
            return .idle
        }
        
        switch childType {
        case .category:
            return .exploringCategory
        case .subcategory:
            return .exploringSubcategory
        case .subSubcategory:
            return .exploringSubSubcategory
        case .datapoint:
            return .selectingDatapoint
        case .me:
            return .idle
        }
    }
}
