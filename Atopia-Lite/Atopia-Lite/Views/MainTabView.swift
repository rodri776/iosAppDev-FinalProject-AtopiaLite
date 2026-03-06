//
//  MainTabView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            UsersTabView()
                .tabItem {
                    Label("Users", systemImage: "person.2.fill")
                }
            
            ProfileTabView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .preferredColorScheme(.dark)
    }
}
