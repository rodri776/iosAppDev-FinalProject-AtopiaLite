//
//  OnboardingFlowView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import CryptoKit

/// Drives the three-step onboarding sequence: location → contacts → interest graph.
struct OnboardingFlowView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var currentStep: OnboardingStep = .location

    /// The pages the user moves through during onboarding.
    enum OnboardingStep {
        case location
        case contacts
        case cluster
    }
    
    var body: some View {
        Group {
            switch currentStep {
            case .location:
                LocationOnboardingView { city, state, neighborhood, lat, lon in
                    print("[Onboarding] Location step complete: city=\(city ?? "nil"), state=\(state ?? "nil"), lat=\(lat ?? 0), lon=\(lon ?? 0)")
                    guard var user = authManager.currentUser else { return }
                    user.city = city
                    user.state = state
                    user.neighborhood = neighborhood
                    user.latitude = lat
                    user.longitude = lon
                    authManager.updateCurrentUser(user)
                    withAnimation {
                        currentStep = .contacts
                        print("[Onboarding] Transitioning to step: contacts")
                    }
                }

            case .contacts:
                ContactsOnboardingView {
                    print("[Onboarding] Contacts step complete")
                    withAnimation {
                        currentStep = .cluster
                        print("[Onboarding] Transitioning to step: cluster")
                    }
                }
                
            case .cluster:
                OnboardingClusterView {
                    print("[Onboarding] Cluster step complete — finishing onboarding")
                    completeOnboarding()
                }
            }
        }
    }
    
    /// Persists the user's saved datapoints, marks onboarding done, and syncs the profile to CloudKit.
    private func completeOnboarding() {
        guard var user = authManager.currentUser else { return }
        let profileManager = UserProfileManager(userId: user.id)
        user.savedDatapoints = Array(profileManager.savedDatapoints)
        user.hasCompletedOnboarding = true
        print("[Onboarding] Onboarding complete for userId=\(user.id), saved \(user.savedDatapoints.count) datapoints, setting hasCompletedOnboarding=true")
        authManager.updateCurrentUser(user)

        // Sync to CloudKit: publish hashed phone + datapoints
        let ck = CloudKitManager.shared
        let hashedPhone: String? = {
            guard let raw = user.phoneNumber else { return nil }
            let digits = String(raw.unicodeScalars.filter(CharacterSet.decimalDigits.contains))
            let hash = SHA256.hash(data: Data(digits.utf8))
            return hash.map { String(format: "%02x", $0) }.joined()
        }()
        let labels = profileManager.savedDatapointLabels

        Task {
            await ck.publishProfile(
                userId: user.id,
                hashedPhone: hashedPhone,
                datapointLabels: labels
            )
        }
    }
}
