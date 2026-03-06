//
//  ProfileTabView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var viewMode: ProfileViewMode = .list
    
    enum ProfileViewMode: String, CaseIterable {
        case list = "List"
        case graph = "Graph"
    }
    
    private var profileManager: UserProfileManager {
        guard let userId = authManager.currentUser?.id else {
            return UserProfileManager()
        }
        return UserProfileManager(userId: userId)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // User info header
                if let user = authManager.currentUser {
                    userHeader(user)
                }
                
                // View mode picker
                Picker("View", selection: $viewMode) {
                    ForEach(ProfileViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Content
                switch viewMode {
                case .list:
                    ProfileListView(profileManager: profileManager)
                case .graph:
                    ProfileGraphView(profileManager: profileManager)
                }
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Out") {
                        authManager.logout()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func userHeader(_ user: LocalUser) -> some View {
        VStack(spacing: 12) {
            // Avatar circle with initials
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 72, height: 72)
                
                Text(String(user.firstName.prefix(1)) + String(user.lastName.prefix(1)))
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 4) {
                Text(user.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let location = user.locationString {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                        Text(location)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            // Stats
            HStack(spacing: 24) {
                VStack {
                    Text("\(profileManager.savedDatapointsCount)")
                        .font(.headline)
                    Text("Datapoints")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding()
    }
}
