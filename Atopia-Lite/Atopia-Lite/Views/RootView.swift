//
//  RootView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showSplash = true
    @State private var showRatingAlert = false
    
    var body: some View {
        ZStack {
            Group {
                if let user = authManager.currentUser {
                    if user.hasCompletedOnboarding {
                        MainTabView()
                            .onAppear { print("[Root] Showing MainTabView for user: \(user.username)") }
                    } else {
                        OnboardingFlowView()
                            .onAppear { print("[Root] Showing OnboardingFlowView for user: \(user.username)") }
                    }
                } else {
                    AuthView()
                        .onAppear { print("[Root] Showing AuthView (no authenticated user)") }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: authManager.currentUser?.hasCompletedOnboarding)
            
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                    .zIndex(1)
                    .onTapGesture { dismissSplash() }
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        dismissSplash()
                    }
            }
        }
        .alert("Enjoying Atopia?", isPresented: $showRatingAlert) {
            Button("Rate in App Store") { }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("Rate this App in the App Store")
        }
    }
    
    private func dismissSplash() {
        print("[Root] Splash screen dismissed")
        withAnimation(.easeOut(duration: 0.4)) {
            showSplash = false
        }
        
        let launchCount = UserDefaults.standard.integer(forKey: "launchCount")
        print("[Root] Launch count: \(launchCount)")
        if launchCount == 3 {
            print("[Root] Showing rating alert (3rd launch)")
            showRatingAlert = true
        }
    }
}

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Image("Logo").resizable().scaledToFit()
                        .frame(width: 150, height: 150)
                    Text("Lite")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .italic(true).padding(.bottom)
                }
                
                Text("Juniper Rodriguez & Alina Li")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
    }
}
