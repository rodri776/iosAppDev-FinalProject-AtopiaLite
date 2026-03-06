//
//  OnboardingClusterView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

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
    
    private func profileManagerForCurrentUser() -> UserProfileManager {
        guard let userId = authManager.currentUser?.id else {
            return UserProfileManager()
        }
        return UserProfileManager(userId: userId)
    }
}
