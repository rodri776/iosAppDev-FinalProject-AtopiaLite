//
//  SimilarityService.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import Foundation
import Combine

@MainActor
class SimilarityService: ObservableObject {
    @Published var results: [UserSimilarityResult] = []
    @Published var isCalculating = false
    
    private let embeddingManager: EmbeddingManager
    
    init(embeddingManager: EmbeddingManager? = nil) {
        self.embeddingManager = embeddingManager ?? EmbeddingManager()
        
        let dataset = DatasetLoader.loadDataset()
        self.embeddingManager.preEmbed(labels: dataset.items.map { $0.label })
    }
    
    struct UserSimilarityResult: Identifiable {
        let user: LocalUser
        let similarity: Double
        let datapointsInCommon: [String]
        let percentageSimilarity: Int
        var id: String { user.id }
    }
    
    func computeSimilarities(currentUser: LocalUser, otherUsers: [LocalUser]) {
        isCalculating = true
        
        Task {
            if !embeddingManager.isReady {
                await embeddingManager.waitUntilReady()
            }
            
            let currentLabels = extractLabels(from: currentUser.savedDatapoints)
            let currentVectors = currentLabels.compactMap { embeddingManager.getEmbedding(for: $0) }
            
            guard let currentCentroid = embeddingManager.calculateCentroid(vectors: currentVectors) else {
                isCalculating = false
                results = otherUsers.map { user in
                    let commonLabels = findCommonLabels(
                        userA: currentUser.savedDatapoints,
                        userB: user.savedDatapoints
                    )
                    return UserSimilarityResult(
                        user: user,
                        similarity: 0,
                        datapointsInCommon: commonLabels,
                        percentageSimilarity: 0
                    )
                }
                return
            }
            
            var computed: [UserSimilarityResult] = []
            
            for other in otherUsers {
                let otherLabels = extractLabels(from: other.savedDatapoints)
                let otherVectors = otherLabels.compactMap { embeddingManager.getEmbedding(for: $0) }
                
                let similarity: Double
                if let otherCentroid = embeddingManager.calculateCentroid(vectors: otherVectors) {
                    let raw = embeddingManager.cosineSimilarity(currentCentroid, otherCentroid)
                    similarity = max(0, min(1, (raw + 1) / 2))
                } else {
                    similarity = 0
                }
                
                let commonLabels = findCommonLabels(
                    userA: currentUser.savedDatapoints,
                    userB: other.savedDatapoints
                )
                
                computed.append(UserSimilarityResult(
                    user: other,
                    similarity: similarity,
                    datapointsInCommon: commonLabels,
                    percentageSimilarity: Int(similarity * 100)
                ))
            }
            
            results = computed.sorted { $0.similarity > $1.similarity }
            isCalculating = false
        }
    }
    
    private func extractLabels(from paths: [String]) -> [String] {
        paths.compactMap { $0.components(separatedBy: "/").last }
    }
    
    private func findCommonLabels(userA: [String], userB: [String]) -> [String] {
        let labelsA = Set(extractLabels(from: userA))
        let labelsB = Set(extractLabels(from: userB))
        return Array(labelsA.intersection(labelsB)).sorted()
    }
}
