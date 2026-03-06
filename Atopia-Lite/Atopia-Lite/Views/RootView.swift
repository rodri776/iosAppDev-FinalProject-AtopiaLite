//
//  RootView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if let user = authManager.currentUser {
                if user.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingFlowView()
                }
            } else {
                AuthView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authManager.currentUser?.hasCompletedOnboarding)
    }
}
