//
//  GraphView.swift
//  The Cluster
//
//  Created by Juniper Rodriguez on 2/26/26.
//

import SwiftUI
struct GraphView: View {
    @ObservedObject var viewModel: GraphViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.clear
                
                // Edges
                ForEach(viewModel.edges) { edge in
                    EdgeView(edge: edge, nodes: viewModel.nodes)
                }
                
                // Nodes
                ForEach(viewModel.nodes) { node in
                    NodeView(
                        node: node,
                        focusState: viewModel.focusState(for: node),
                        onTap: {
                            viewModel.toggleNode(nodeId: node.id)
                        }
                    )
                    .position(node.position)
                }
            }
            .scaleEffect(viewModel.zoomScale)
            .offset(viewModel.panOffset)
            .onAppear {
                viewModel.setupInitialNode(in: geometry.size)
            }
        }
    }
}

