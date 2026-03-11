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
                .tabItem { Label("Contacts", systemImage: "person.3.fill") }

            UsersMapView()
                .tabItem { Label("Map", systemImage: "map.fill") }

            ProfileTabView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(.green)
    }
}
