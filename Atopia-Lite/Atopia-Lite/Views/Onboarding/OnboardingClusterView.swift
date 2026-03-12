//
//  OnboardingClusterView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

/// Thin wrapper that hosts the interest graph during onboarding so the user can pick their first datapoints.
struct OnboardingClusterView: View {
    @EnvironmentObject var authManager: AuthManager
    var onComplete: () -> Void
    
    var body: some View {
        ClusterContentView(
            isOnboarding: true,
            profileManager: profileManagerForCurrentUser(),
            onOnboardingComplete: onComplete
        )
    }
    
    /// Builds a UserProfileManager scoped to the logged-in user's ID.
    private func profileManagerForCurrentUser() -> UserProfileManager {
        guard let userId = authManager.currentUser?.id else {
            return UserProfileManager()
        }
        return UserProfileManager(userId: userId)
    }
}
