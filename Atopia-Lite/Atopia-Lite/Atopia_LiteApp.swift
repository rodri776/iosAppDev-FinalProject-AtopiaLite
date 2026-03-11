//
//  Atopia_LiteApp.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

@main
struct Atopia_LiteApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        UserDefaults.standard.register(defaults: [
            "version_preference": "1.0",
            "created_by_preference": "Juniper Rodriguez & Alina Li"
        ])
        
        if UserDefaults.standard.object(forKey: "Initial Launch") == nil {
            UserDefaults.standard.set(Date(), forKey: "Initial Launch")
        }
        
        let count = UserDefaults.standard.integer(forKey: "launchCount")
        UserDefaults.standard.set(count + 1, forKey: "launchCount")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .fontDesign(.serif)
                .environmentObject(authManager)
        }
    }
}
