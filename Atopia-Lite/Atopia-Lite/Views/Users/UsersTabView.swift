//
//  UsersTabView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import UIKit

struct UsersTabView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var similarityService = SimilarityService()
    @State private var selectedResult: SimilarityService.UserSimilarityResult?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("ATOPIA").font(.largeTitle.bold()).fontDesign(.serif)

                if similarityService.isCalculating {
                    Spacer()
                    ProgressView()
                    Text("Computing similarities...").font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                } else if similarityService.results.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("No matches yet").font(.title2.bold())
                        Text("Try adding more datapoints.").foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(similarityService.results) { result in
                                UserCard(result: result)
                                    .onTapGesture {
                                        print("[UsersTab] User card tapped: \(result.user.displayName) (\(result.percentageSimilarity)% match)")
                                        selectedResult = result
                                    }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding(20)
            .background(Color("BackgroundColor").ignoresSafeArea())
            .sheet(item: $selectedResult) { result in
                UserDetailSheet(result: result)
            }
        }
        .onAppear {
            print("[UsersTab] View appeared")
            if let user = authManager.currentUser, similarityService.results.isEmpty {
                print("[UsersTab] Computing similarities for user: \(user.username) against \(MockUsers.all.count) mock users")
                similarityService.computeSimilarities(currentUser: user, otherUsers: MockUsers.all)
            }
        }
    }
}

// MARK: - User Card

struct UserCard: View {
    let result: SimilarityService.UserSimilarityResult

    private static let datasetItems: [DataItem] = DatasetLoader.loadDataset().items
    private let maxChips = 3

    // Resolve common datapoint IDs to display labels
    private var commonDisplayLabels: [String] {
        result.datapointsInCommon.sorted().compactMap { dpId in
            Self.datasetItems.first(where: { $0.id == dpId })?.label ?? dpId
        }
    }

    private var displayedLabels: [String] {
        Array(commonDisplayLabels.prefix(maxChips))
    }

    private var extraCount: Int {
        max(0, commonDisplayLabels.count - maxChips)
    }

    var body: some View {
        VStack(spacing: 14) {
            // Top row: avatar, name, percentage
            HStack(alignment: .top) {
                Circle()
                    .fill(Color(.systemGray4).opacity(0.5))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(String(result.user.firstName.prefix(1) + result.user.lastName.prefix(1)).uppercased())
                            .font(.title3.bold())
                            .foregroundStyle(Color(.darkGray))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.user.abbreviatedName)
                        .font(.title3.bold())
                    Text("@\(result.user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(result.percentageSimilarity)%")
                    .font(.title3.bold())
                    .foregroundStyle(Color("SavedGreen"))
            }

            // Common datapoint chips (max 3) + "+N more"
            if !commonDisplayLabels.isEmpty {
                HStack(spacing: 8) {
                    ForEach(displayedLabels, id: \.self) { label in
                        Text(label.uppercased())
                            .font(.caption2.bold())
                            .lineLimit(1)
                            .padding(.horizontal, 10).padding(.vertical, 7)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    if extraCount > 0 {
                        Text("+\(extraCount) more")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }

            // Suggest Hangout button
            Button {
                print("[UsersTab] 'Suggest Hangout' tapped for \(result.user.displayName)")
                if let phone = result.user.phoneNumber,
                   let url = URL(string: "sms:\(phone)") {
                    print("[UsersTab] Opening SMS URL: \(url)")
                    UIApplication.shared.open(url)
                } else {
                    print("[UsersTab] No phone number for \(result.user.displayName)")
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.subheadline.bold())
                    Text("Suggest Hangout")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color("SavedGreen"))
                .clipShape(Capsule())
            }
        }
        .padding(18)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - User Detail Sheet

struct UserDetailSheet: View {
    let result: SimilarityService.UserSimilarityResult
    @Environment(\.dismiss) private var dismiss

    private static let datasetItems: [DataItem] = DatasetLoader.loadDataset().items

    // Map each saved datapoint ID to its DataItem
    private var resolvedDatapoints: [DataItem] {
        result.user.savedDatapoints.compactMap { dpId in
            Self.datasetItems.first { $0.id == dpId }
        }
    }

    // Group datapoints by category
    private var groupedByCategory: [(category: String, items: [DataItem])] {
        var dict: [String: [DataItem]] = [:]
        for dp in resolvedDatapoints {
            let key = dp.category.uppercased()
            dict[key, default: []].append(dp)
        }
        return dict.sorted { $0.key < $1.key }.map { (category: $0.key, items: $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Centered header
                    VStack(spacing: 10) {
                        Circle()
                            .fill(Color(.systemGray4).opacity(0.5))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(result.user.firstName.prefix(1) + result.user.lastName.prefix(1)).uppercased())
                                    .font(.title.bold())
                                    .foregroundStyle(Color(.darkGray))
                            )

                        Text(result.user.abbreviatedName)
                            .font(.title2.bold())

                        Text("@\(result.user.username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Match badge
                        Text("\(result.percentageSimilarity)% MATCH")
                            .font(.caption.bold())
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            .background(Color("SavedGreen").opacity(0.15))
                            .foregroundStyle(Color("SavedGreen"))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color("SavedGreen"), lineWidth: 1)
                            )

                        // Suggest Hangout button
                        Button {
                            print("[UserDetail] 'Suggest Hangout' tapped for \(result.user.displayName)")
                            if let phone = result.user.phoneNumber,
                               let url = URL(string: "sms:\(phone)") {
                                print("[UserDetail] Opening SMS URL: \(url)")
                                UIApplication.shared.open(url)
                            } else {
                                print("[UserDetail] No phone number for \(result.user.displayName)")
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                Text("Suggest Hangout")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(Color("SavedGreen"))
                            .padding(.horizontal, 24).padding(.vertical, 10)
                            .background(
                                Capsule().stroke(Color("SavedGreen"), lineWidth: 1.5)
                            )
                        }
                    }
                    .padding(.top, 8)

                    // Datapoints section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DATAPOINTS")
                            .font(.headline.bold())
                            .tracking(1)

                        ForEach(groupedByCategory, id: \.category) { group in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(group.category)
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                    .tracking(0.5)

                                FlowLayout(spacing: 8) {
                                    ForEach(group.items, id: \.id) { item in
                                        Text(item.label.uppercased())
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 12).padding(.vertical, 8)
                                            .background(Color(.systemGray5))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(20)
            }
            .background(Color("BackgroundColor"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
