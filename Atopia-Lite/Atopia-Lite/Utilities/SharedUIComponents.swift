//
//  SharedUIComponents.swift
//  Atopia
//
//  Created by Juniper Rodriguez on 2/26/26.
//

import SwiftUI

extension View {
    func fieldStyle() -> some View {
        self
            .padding()
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

@ViewBuilder
func plainChip(_ text: String) -> some View {
    Text(text.uppercased())
        .font(.caption2)
        .fontWeight(.medium)
        .tracking(0.5)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.1))
        .foregroundColor(Color.accentColor)
        .cornerRadius(12)
}

@ViewBuilder
func bgChip(_ icon: String, _ text: String, _ label: String) -> some View {
    HStack(spacing: 6) {
        Text(icon)
            .font(.caption)
        VStack(alignment: .leading, spacing: 2) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
        }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color.primary.opacity(0.05))
    .cornerRadius(12)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
    )
}

@ViewBuilder
func categoryTab(_ icon: String, _ name: String, _ count: Int, _ selected: Bool) -> some View {
    HStack(spacing: 6) {
        Text(icon)
            .font(.caption2)
        Text(name.uppercased())
            .font(.system(size: 10))
            .fontWeight(.semibold)
            .tracking(0.5)
        Text("\(count)")
            .font(.system(size: 9))
            .foregroundColor(.secondary)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(selected ? Color.accentColor.opacity(0.15) : Color.clear)
    .foregroundColor(selected ? Color.accentColor : .primary)
    .cornerRadius(20)
    .overlay(
        RoundedRectangle(cornerRadius: 20)
            .stroke(selected ? Color.accentColor : Color.primary.opacity(0.1), lineWidth: 1)
    )
}

@ViewBuilder
func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .tracking(2)
            .foregroundColor(.secondary)
        
        content()
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.primary.opacity(0.03))
    .cornerRadius(16)
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
    )
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

