//
//  UsersMapView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import MapKit

/// Map view that plots the current user and matched users with similarity-percentage annotations.
struct UsersMapView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var similarityService = SimilarityService()
    @State private var selectedResult: SimilarityService.UserSimilarityResult?

    var body: some View {
        NavigationStack {
            Map {
                if let user = authManager.currentUser,
                   let lat = user.latitude, let lon = user.longitude {
                    Marker("You", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        .tint(.green)
                }

                ForEach(similarityService.results) { result in
                    if let lat = result.user.latitude, let lon = result.user.longitude {
                        Annotation(result.user.displayName,
                                   coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                            Button {
                                print("[Map] Annotation tapped: \(result.user.displayName) (\(result.percentageSimilarity)% match) at lat=\(lat), lon=\(lon)")
                                selectedResult = result
                            } label: {
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
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(result.user.displayName), \(result.percentageSimilarity)% match")
                            .accessibilityHint("Shows profile details")
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedResult) { result in
                UserDetailSheet(result: result)
            }
        }
        .onAppear {
            print("[Map] UsersMapView appeared")
            if let user = authManager.currentUser, similarityService.results.isEmpty {
                print("[Map] Computing similarities for map: user=\(user.username), lat=\(user.latitude ?? 0), lon=\(user.longitude ?? 0)")
                similarityService.computeSimilarities(currentUser: user, otherUsers: MockUsers.all)
            }
        }
    }
}
