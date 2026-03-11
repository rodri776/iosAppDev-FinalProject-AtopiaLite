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
    @State private var hashedContactPhones: Set<String> = []

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
                ContactsOnboardingView { phones in
                    hashedContactPhones = phones
                    print("[Onboarding] Contacts step complete: \(phones.count) hashed phone numbers")
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
    
    private func completeOnboarding() {
        guard var user = authManager.currentUser else { return }
        let profileManager = UserProfileManager(userId: user.id)
        user.savedDatapoints = Array(profileManager.savedDatapoints)
        user.hasCompletedOnboarding = true
        print("[Onboarding] Onboarding complete for userId=\(user.id), saved \(user.savedDatapoints.count) datapoints, setting hasCompletedOnboarding=true")
        authManager.updateCurrentUser(user)

        // Sync to CloudKit: publish hashed phone + datapoints, discover contacts
        let ck = CloudKitManager.shared
        let hashedPhone: String? = {
            guard let raw = user.phoneNumber else { return nil }
            return ContactsOnboardingView.sha256(
                ContactsOnboardingView.normalizePhone(raw)
            )
        }()
        let labels = profileManager.savedDatapointLabels

        Task {
            await ck.publishProfile(
                userId: user.id,
                hashedPhone: hashedPhone,
                datapointLabels: labels
            )

            if !hashedContactPhones.isEmpty {
                let discovered = await ck.discoverUsers(
                    matchingHashedPhones: hashedContactPhones
                )
                print("[Onboarding] CloudKit discovered \(discovered.count) matching users")
            }
        }
    }
}
