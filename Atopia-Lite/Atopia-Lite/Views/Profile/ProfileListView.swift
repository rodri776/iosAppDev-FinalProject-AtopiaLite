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
            VStack(spacing: 12) {
                Image(systemName: "circle.hexagongrid")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(.secondary)
                Text("No Datapoints Yet")
                    .font(.headline)
                Text("Explore the graph to save datapoints that describe you")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(savedCategories) { category in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.name.uppercased())
                            .font(.headline).foregroundStyle(.secondary)

                        ForEach(category.datapoints) { dp in
                            Text(dp.label.uppercased())
                                .font(.headline.bold())
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
}
