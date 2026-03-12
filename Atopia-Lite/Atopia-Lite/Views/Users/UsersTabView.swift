//
//  UsersTabView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

/// Lists all users ranked by similarity score, with cards showing shared interests.
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
    @State private var showCreateHangout = false
    @State private var showScoreInfo = false

    private let maxChips = 3

    private var commonDisplayLabels: [String] {
        result.datapointsInCommon.sorted()
    }

    private var displayedLabels: [String] {
        Array(commonDisplayLabels.prefix(maxChips))
    }

    private var extraCount: Int {
        max(0, commonDisplayLabels.count - maxChips)
    }

    private var cardSummary: String {
        var summary = "\(result.user.abbreviatedName), \(result.percentageSimilarity)% match"
        if !commonDisplayLabels.isEmpty {
            summary += ". Common interests: \(commonDisplayLabels.joined(separator: ", "))"
            if extraCount > 0 {
                summary += ", and \(extraCount) more"
            }
        }
        return summary
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color(.systemGray4).opacity(0.5))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(String(result.user.firstName.prefix(1) + result.user.lastName.prefix(1)).uppercased())
                            .font(.title3.bold())
                            .foregroundStyle(Color(.darkGray))
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.user.abbreviatedName)
                        .font(.title3.bold())
                    Text("@\(result.user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("\(result.percentageSimilarity)%")
                        .font(.title3.bold())
                        .foregroundStyle(Color("SavedGreen"))

                    Button {
                        showScoreInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Match score info")
                    .accessibilityHint("Explains how the match percentage is calculated")
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(cardSummary)
            .accessibilityHint("Shows full profile")

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
                .accessibilityHidden(true)
            }

            Button {
                print("[UsersTab] 'Create Hangout' tapped for \(result.user.displayName)")
                showCreateHangout = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.subheadline.bold())
                    Text("Create Hangout")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color("SavedGreen"))
                .clipShape(Capsule())
            }
            .accessibilityLabel("Create Hangout with \(result.user.abbreviatedName)")
            .sheet(isPresented: $showCreateHangout) {
                CreateHangoutSheet(
                    userName: result.user.displayName,
                    phoneNumber: result.user.phoneNumber
                )
            }
        }
        .padding(18)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .alert("Match Score", isPresented: $showScoreInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This percentage shows how similar your interests are to this person's, based on shared datapoints and the semantic similarity of your profiles.")
        }
    }
}

// MARK: - User Detail Sheet

/// Full-screen sheet showing a user's profile, match score, and all their datapoints grouped by category.
struct UserDetailSheet: View {
    let result: SimilarityService.UserSimilarityResult
    @Environment(\.dismiss) private var dismiss
    @State private var showCreateHangout = false
    @State private var showScoreInfo = false

    private static let datasetItems: [DataItem] = DatasetLoader.loadDataset().items

    private var resolvedDatapoints: [DataItem] {
        result.user.savedDatapoints.compactMap { path in
            let label = path.components(separatedBy: UserProfileManager.pathSeparator).last ?? path
            return Self.datasetItems.first { $0.label == label }
        }
    }

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
                    VStack(spacing: 10) {
                        Circle()
                            .fill(Color(.systemGray4).opacity(0.5))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(result.user.firstName.prefix(1) + result.user.lastName.prefix(1)).uppercased())
                                    .font(.title.bold())
                                    .foregroundStyle(Color(.darkGray))
                            )
                            .accessibilityHidden(true)

                        Text(result.user.abbreviatedName)
                            .font(.title2.bold())

                        Text("@\(result.user.username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 6) {
                            Text("\(result.percentageSimilarity)% MATCH")
                                .font(.caption.bold())
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(Color("SavedGreen").opacity(0.15))
                                .foregroundStyle(Color("SavedGreen"))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color("SavedGreen"), lineWidth: 1)
                                )

                            Button {
                                showScoreInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel("Match score info")
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(result.percentageSimilarity) percent match")

                        // Create Hangout button
                        Button {
                            print("[UserDetail] 'Create Hangout' tapped for \(result.user.displayName)")
                            showCreateHangout = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                Text("Create Hangout")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(Color("SavedGreen"))
                            .padding(.horizontal, 24).padding(.vertical, 10)
                            .background(
                                Capsule().stroke(Color("SavedGreen"), lineWidth: 1.5)
                            )
                        }
                        .accessibilityLabel("Create Hangout with \(result.user.abbreviatedName)")
                        .sheet(isPresented: $showCreateHangout) {
                            CreateHangoutSheet(
                                userName: result.user.displayName,
                                phoneNumber: result.user.phoneNumber
                            )
                        }
                    }
                    .padding(.top, 8)

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
            .alert("Match Score", isPresented: $showScoreInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This percentage shows how similar your interests are to this person's, based on shared datapoints and the semantic similarity of your profiles.")
            }
        }
    }
}
