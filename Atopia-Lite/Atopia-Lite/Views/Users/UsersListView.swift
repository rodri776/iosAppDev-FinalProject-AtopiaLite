//
//  UsersListView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct UsersListView: View {
    let results: [SimilarityService.UserSimilarityResult]
    
    var body: some View {
        if results.isEmpty {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "person.2")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.secondary)
                Text("No users to show")
                    .font(.headline)
                Text("Save some datapoints to see how you compare")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        } else {
            List(results) { result in
                UserRow(result: result)
            }
            .listStyle(.plain)
        }
    }
}

struct UserRow: View {
    let result: SimilarityService.UserSimilarityResult
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Text(String(result.user.firstName.prefix(1)) + String(result.user.lastName.prefix(1)))
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(.accentColor)
                }
                
                // Name and username
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.user.displayName)
                        .font(.headline)
                    
                    Text("@\(result.user.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let bio = result.user.bio {
                        Text(bio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Similarity percentage
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(result.percentageSimilarity)%")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(similarityColor)
                    
                    Text("\(result.datapointsInCommon.count) in common")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Location
            if let location = result.user.locationString {
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.caption2)
                    Text(location)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            // Expandable common datapoints
            if !result.datapointsInCommon.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Datapoints in common")
                            .font(.caption)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                
                if isExpanded {
                    FlowLayout(spacing: 6) {
                        ForEach(result.datapointsInCommon, id: \.self) { label in
                            Text(label)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var similarityColor: Color {
        if result.percentageSimilarity >= 80 {
            return .green
        } else if result.percentageSimilarity >= 60 {
            return .yellow
        } else if result.percentageSimilarity >= 40 {
            return .orange
        } else {
            return .secondary
        }
    }
}
