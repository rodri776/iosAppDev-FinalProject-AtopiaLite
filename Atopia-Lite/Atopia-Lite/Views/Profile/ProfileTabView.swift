//
//  ProfileTabView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var authManager: AuthManager

    private var profileManager: UserProfileManager {
        guard let userId = authManager.currentUser?.id else { return UserProfileManager() }
        return UserProfileManager(userId: userId)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if let user = authManager.currentUser {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text(initials(user))
                                        .font(.system(size: 40, weight: .bold, design: .serif))
                                        .foregroundStyle(.gray)
                                )

                            Text(user.displayName)
                                .font(.system(size: 28, weight: .bold, design: .serif))

                            Text("@\(user.username)")
                                .foregroundStyle(.secondary)
                        }

                        profileSection("DATAPOINTS") {
                            ProfileListView(profileManager: profileManager)
                        }
                    }
                }
                .padding(20)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Out") { authManager.logout() }
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func initials(_ user: LocalUser) -> String {
        let f = user.firstName.prefix(1)
        let l = user.lastName.prefix(1)
        let value = "\(f)\(l)"
        return value.isEmpty ? "?" : value.uppercased()
    }

    @ViewBuilder
    private func profileSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.headline).tracking(2)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
