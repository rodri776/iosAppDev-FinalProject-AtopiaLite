//
//  UsersTabView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct UsersTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var similarityService = SimilarityService()
    @State private var viewMode: UsersViewMode = .list
    
    enum UsersViewMode: String, CaseIterable {
        case list = "List"
        case map = "Map"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $viewMode) {
                    ForEach(UsersViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if similarityService.isCalculating {
                    VStack(spacing: 12) {
                        Spacer()
                        ProgressView()
                        Text("Calculating similarities...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    switch viewMode {
                    case .list:
                        UsersListView(results: similarityService.results)
                    case .map:
                        UsersMapView(results: similarityService.results)
                    }
                }
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if let user = authManager.currentUser, similarityService.results.isEmpty {
                similarityService.computeSimilarities(
                    currentUser: user,
                    otherUsers: MockUsers.all
                )
            }
        }
    }
}
