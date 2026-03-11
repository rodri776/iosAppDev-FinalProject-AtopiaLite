//
//  UsersMapView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import MapKit

struct UsersMapView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var similarityService = SimilarityService()

    var body: some View {
        NavigationStack {
            Map {
                // Current user marker
                if let user = authManager.currentUser,
                   let lat = user.latitude, let lon = user.longitude {
                    Marker("You", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        .tint(.green)
                }

                // Other users
                ForEach(similarityService.results) { result in
                    if let lat = result.user.latitude, let lon = result.user.longitude {
                        Annotation(result.user.displayName,
                                   coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                            VStack(spacing: 2) {
                                Text("\(result.percentageSimilarity)%")
                                    .font(.caption2.bold()).foregroundStyle(.white)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.green).clipShape(Capsule())

                                Circle().fill(Color.pink.opacity(0.18))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text(String(result.user.firstName.prefix(1)).uppercased())
                                            .font(.subheadline.bold()).foregroundStyle(.pink)
                                    )
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if let user = authManager.currentUser, similarityService.results.isEmpty {
                similarityService.computeSimilarities(currentUser: user, otherUsers: MockUsers.all)
            }
        }
    }
}
