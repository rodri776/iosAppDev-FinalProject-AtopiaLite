//
//  EdgeView.swift
//  TheCluster
//
//  Created by Juniper Rodriguez on 2/16/26.
//
import SwiftUI

struct EdgeView: View {
    let fromNode: Node
    let toNode: Node
    let thickness: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: fromNode.position)
            path.addLine(to: toNode.position)
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: thickness)
    }
}

extension EdgeView {
    init(edge: Edge, nodes: [Node]) {
        let fromNode = nodes.first(where: { $0.id == edge.fromId }) ?? Node(position: .zero, label: "", type: .me)
        let toNode = nodes.first(where: { $0.id == edge.toId }) ?? Node(position: .zero, label: "", type: .me)
        self.init(fromNode: fromNode, toNode: toNode, thickness: edge.thickness)
    }
}

