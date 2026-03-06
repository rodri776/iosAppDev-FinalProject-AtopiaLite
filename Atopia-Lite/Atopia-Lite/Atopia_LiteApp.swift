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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .fontDesign(.serif)
                .environmentObject(authManager)
        }
    }
}
