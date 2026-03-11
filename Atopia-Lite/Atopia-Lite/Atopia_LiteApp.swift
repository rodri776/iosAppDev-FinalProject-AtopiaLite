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
        print("[App] Atopia-Lite launching")
        
        UserDefaults.standard.register(defaults: [
            "version_preference": "1.0",
            "created_by_preference": "Juniper Rodriguez & Alina Li"
        ])
        print("[App] UserDefaults registered: version=1.0, created_by=Juniper Rodriguez & Alina Li")
        
        if UserDefaults.standard.object(forKey: "Initial Launch") == nil {
            let now = Date()
            UserDefaults.standard.set(now, forKey: "Initial Launch")
            print("[App] First launch recorded at: \(now)")
        }
        
        let count = UserDefaults.standard.integer(forKey: "launchCount")
        UserDefaults.standard.set(count + 1, forKey: "launchCount")
        print("[App] Launch count: \(count + 1)")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .fontDesign(.serif)
                .environmentObject(authManager)
        }
    }
}
