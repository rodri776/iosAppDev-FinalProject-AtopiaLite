//
//  NodeView.swift
//  TheCluster
//
//  Created by Juniper Rodriguez on 2/16/26.
//

import SwiftUI

struct NodeView: View {
    let node: Node
    let focusState: NodeFocusState
    let onTap: () -> Void
    
    @State private var isPulsing = false
    
    private var displayLabel: String {
        switch node.type {
        case .subcategory, .subSubcategory:
            return node.label.replacingOccurrences(of: "_", with: "/")
        default:
            return node.label
        }
    }
    
    private var visualOpacity: Double {
        switch focusState {
        case .normal: return 1.0
        case .highlighted: return 1.0
        case .dimmed: return 0.25
        }
    }
    
    private var visualSaturation: Double {
        switch focusState {
        case .normal: return 1.0
        case .highlighted: return 1.0
        case .dimmed: return 0.3
        }
    }
    
    private var visualScale: CGFloat {
        switch focusState {
        case .normal: return 1.0
        case .highlighted: return 1.0
        case .dimmed: return 0.85
        }
    }
    
    var body: some View {
        ZStack {
            // Recommendation aura
            if node.isRecommended && !node.isSavedToProfile {
                Capsule()
                    .fill(Color("RecPurple1").opacity(0.4))
                    .frame(width: max(sizeForNode, node.textWidth + 20) + 24, height: sizeForNode + 24)
                    .blur(radius: 10)
                    .shadow(color: Color("RecPurple1").opacity(0.5), radius: 12, x: 0, y: 0)
            }
            
            // Expanded ring
            if node.isExpanded && !node.childIds.isEmpty {
                Capsule()
                    .stroke(
                        Color("ExpandedGreen"),
                        lineWidth: 4
                    )
                    .frame(
                        width: max(sizeForNode, node.textWidth + 20) + 8,
                        height: sizeForNode + 8
                    )
                    .opacity(0.8)
                    .shadow(color: Color("ExpandedGreen").opacity(0.5), radius: 8, x: 0, y: 0)
            }
            
            // Glow
            if node.isRecommended && !node.isSavedToProfile {
                Capsule()
                    .fill(Color("RecPurple1").opacity(0.3))
                    .blur(radius: 12)
                    .scaleEffect(1.2)
            } else {
                let hasSelectedChildren = node.type != .datapoint && node.savedCount > 0
                let isSelected = (node.type == .me) || (node.type == .datapoint && node.isSavedToProfile) || hasSelectedChildren
                
                if isSelected {
                    Capsule()
                        .fill(node.color.opacity(node.type == .me ? 0.24 : 0.18))
                        .blur(radius: node.type == .me ? 10 : 6)
                        .opacity(node.type == .me ? 0.24 : 0.18)
                        .scaleEffect(node.isExpanded ? 1.1 : 1.05)
                } else {
                    Capsule()
                        .fill(gradientForNode)
                        .blur(radius: 5)
                        .opacity(0.18)
                        .scaleEffect(1.05)
                }
            }
            
            switch node.type {
            case .me:
                Capsule()
                    .fill(gradientForNode)
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                node.isExpanded ? node.color.opacity(0.7) : node.color.opacity(0.5),
                                lineWidth: node.isExpanded ? 5 : 3.5
                            )
                    )
                    .overlay(
                        // Subtle ring animation when expanded
                        Group {
                            if node.isExpanded {
                                Capsule()
                                    .stroke(node.color.opacity(0.5), lineWidth: 4)
                                    .scaleEffect(1.15)
                                    .opacity(0.5)
                                    .animation(
                                        Animation.easeInOut(duration: 1.2)
                                            .repeatForever(autoreverses: true),
                                        value: node.isExpanded
                                    )
                            }
                        }
                    )
                    .scaleEffect(1.4)
                    .shadow(color: Color.black.opacity(0.16), radius: 6, x: -2, y: 2)
                    .shadow(
                        color: Color("SavedGreen").opacity(isPulsing ? 0.8 : 0.3),
                        radius: isPulsing ? 20 : 10,
                        x: 0,
                        y: 0
                    )
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                        ) {
                            isPulsing = true
                        }
                    }
                
            case .category:
                Capsule()
                    .fill(gradientForNode)
                    .overlay(
                        Capsule()
                            .stroke(
                                (node.savedCount > 0) ?
                                    Color("SavedGreen").opacity(0.7) : Color.white.opacity(0.2),
                                lineWidth: (node.savedCount > 0) ? 3 : 2
                            )
                    )
                    .scaleEffect(1.15)
                
            case .subcategory, .subSubcategory:
                Capsule()
                    .fill(gradientForNode)
                    .overlay(
                        Capsule()
                            .stroke(
                                (node.savedCount > 0) ?
                                    Color("SavedGreen").opacity(0.7) : Color.white.opacity(0.2),
                                lineWidth: (node.savedCount > 0) ? 3 : 2
                            )
                    )
                    .scaleEffect(1.0)
                
            case .datapoint:
                Capsule()
                    .fill(gradientForNode)
                    .overlay(
                        Capsule()
                            .stroke(
                                node.isSavedToProfile ?
                                    Color("SavedGreen").opacity(0.7) : Color.white.opacity(0.2),
                                lineWidth: node.isSavedToProfile ? 3 : 2
                            )
                    )
                    .scaleEffect(0.9)
            }
            
            // Saved checkmark
            if node.type == .datapoint && node.isSavedToProfile {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("SavedGreen"))
                    .offset(x: max(sizeForNode, node.textWidth + 20) / 2 - 14, y: -sizeForNode / 2 + 10)
            }
            
            // Recommendation sparkle
            if node.isRecommended && !node.isSavedToProfile {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("RecPurple1"))
                    .offset(x: max(sizeForNode, node.textWidth + 20) / 2 - 14, y: -sizeForNode / 2 + 10)
                    .shadow(color: Color("RecPurple1").opacity(0.8), radius: 4, x: 0, y: 0)
            }
            
            HStack(spacing: 2) {
                Text(displayLabel)
                    .font(
                        .system(
                            size: node.type == .me ? 16 : 14,
                            weight: node.isExpanded ? (node.type == .me ? .heavy : .bold) : .semibold,
                            design: .serif
                        )
                    )
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: true, vertical: false)
                
                if node.savedCount > 0 && node.type != .datapoint {
                    Text("(\(node.savedCount))")
                        .font(.system(size: node.type == .me ? 14 : 12, weight: .medium, design: .serif))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .frame(width: max(sizeForNode, node.textWidth + 20), height: sizeForNode)
        .scaleEffect(
                (node.type == .me ? 1.4 :
                    (node.type == .category ? 1.15 :
                        (node.type == .subcategory || node.type == .subSubcategory ? 1.0 : 0.9))
                ) * visualScale
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: node.isExpanded)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: node.isSavedToProfile)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: node.isRecommended)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: focusState)
        .onTapGesture {
            onTap()
        }
        .opacity(visualOpacity)
        .saturation(visualSaturation)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(nodeAccessibilityLabel)
        .accessibilityHint(nodeAccessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
    
    var sizeForNode: CGFloat {
        switch node.type {
        case .me: return 70
        case .category: return 80
        case .subcategory: return 70
        case .subSubcategory: return 60
        case .datapoint: return 50
        }
    }
    
    var gradientForNode: LinearGradient {
        if node.isRecommended && !node.isSavedToProfile {
            return LinearGradient(
                colors: [
                    Color("RecPurple1").opacity(0.9),
                    Color("RecPurple2").opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        let hasSelectedChildren = node.type != .datapoint && node.savedCount > 0
        let isSelected = (node.type == .me) || (node.type == .datapoint && node.isSavedToProfile) || hasSelectedChildren
        
        if isSelected {
            return LinearGradient(
                colors: [
                    Color("SavedGreen"),
                    Color("SavedGreen")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    node.color.opacity(0.9),
                    node.color.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var nodeAccessibilityLabel: String {
        var label = displayLabel
        switch node.type {
        case .me: label = "Me, start node"
        case .category: label = "\(displayLabel) category"
        case .subcategory: label = "\(displayLabel) subcategory"
        case .subSubcategory: label = "\(displayLabel) sub-subcategory"
        case .datapoint:
            if node.isRecommended && !node.isSavedToProfile {
                label = "\(displayLabel), recommended"
            } else if node.isSavedToProfile {
                label = "\(displayLabel), saved to profile"
            } else {
                label = "\(displayLabel) datapoint"
            }
        }
        if node.savedCount > 0 && node.type != .datapoint {
            label += ", \(node.savedCount) saved"
        }
        if node.isExpanded {
            label += ", expanded"
        }
        return label
    }
    
    private var nodeAccessibilityHint: String {
        switch node.type {
        case .me:
            return node.isExpanded ? "Double tap to collapse" : "Double tap to explore categories"
        case .category, .subcategory, .subSubcategory:
            return node.isExpanded ? "Double tap to collapse" : "Double tap to expand"
        case .datapoint:
            return node.isSavedToProfile ? "Double tap to remove from profile" : "Double tap to save to profile"
        }
    }
    
}

