//
//  ProfileListView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct ProfileListView: View {
    let profileManager: UserProfileManager
    
    private var savedCategories: [SavedCategory] {
        let result = DatasetLoader.loadDataset()
        return profileManager.getSavedDatapointsByCategory(allDataItems: result.items)
    }
    
    var body: some View {
        if savedCategories.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(savedCategories) { category in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 10, height: 10)
                                
                                Text(category.name.uppercased())
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .tracking(1)
                            }
                            
                            FlowLayout(spacing: 8) {
                                ForEach(category.datapoints) { dp in
                                    DatapointChip(datapoint: dp, category: category)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "circle.hexagongrid")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.secondary)
            
            Text("No Datapoints Yet")
                .font(.headline)
            
            Text("Explore the graph to save datapoints that describe you")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}
