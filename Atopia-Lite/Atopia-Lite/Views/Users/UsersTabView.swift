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
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding(20)
            .background(Color("BackgroundColor").ignoresSafeArea())
        }
        .onAppear {
            if let user = authManager.currentUser, similarityService.results.isEmpty {
                similarityService.computeSimilarities(currentUser: user, otherUsers: MockUsers.all)
            }
        }
    }
}

struct UserCard: View {
    let result: SimilarityService.UserSimilarityResult

    private var allLabels: [String] {
        result.user.savedDatapoints
            .compactMap { $0.components(separatedBy: "/").last }
            .sorted()
    }

    private var commonSet: Set<String> {
        Set(result.datapointsInCommon)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Circle()
                    .fill(Color.pink.opacity(0.18))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(String(result.user.firstName.prefix(1) + result.user.lastName.prefix(1)).uppercased())
                            .font(.title3.bold()).foregroundStyle(.pink)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(result.user.displayName).font(.title2.bold())
                    Text("@\(result.user.username)").foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 8) {
                    Text("\(result.percentageSimilarity)%")
                        .font(.title3.bold()).foregroundStyle(.green)
                    
                    if let phone = result.user.phoneNumber {
                        Button {
                            if let url = URL(string: "sms:\(phone)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Image(systemName: "message.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                    }
                }
            }

            if let location = result.user.locationString {
                HStack(spacing: 4) {
                    Image(systemName: "mappin").font(.caption2)
                    Text(location).font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            if !allLabels.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(allLabels, id: \.self) { label in
                        let isCommon = commonSet.contains(label)
                        Text(label.uppercased())
                            .font(.caption.bold())
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(isCommon ? Color.green.opacity(0.2) : Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
