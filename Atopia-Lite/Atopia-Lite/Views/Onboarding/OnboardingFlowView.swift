//
//  OnboardingFlowView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var currentStep: OnboardingStep = .location
    
    enum OnboardingStep {
        case location
        case contacts
        case cluster
    }
    
    var body: some View {
        Group {
            switch currentStep {
            case .location:
                LocationOnboardingView { city, state, lat, lon in
                    guard var user = authManager.currentUser else { return }
                    user.city = city
                    user.state = state
                    user.latitude = lat
                    user.longitude = lon
                    authManager.updateCurrentUser(user)
                    withAnimation {
                        currentStep = .contacts
                    }
                }
                
            case .contacts:
                ContactsOnboardingView {
                    withAnimation {
                        currentStep = .cluster
                    }
                }
                
            case .cluster:
                OnboardingClusterView {
                    completeOnboarding()
                }
            }
        }
    }
    
    private func completeOnboarding() {
        guard var user = authManager.currentUser else { return }
        let profileManager = UserProfileManager(userId: user.id)
        user.savedDatapoints = Array(profileManager.savedDatapoints)
        user.hasCompletedOnboarding = true
        authManager.updateCurrentUser(user)
    }
}
