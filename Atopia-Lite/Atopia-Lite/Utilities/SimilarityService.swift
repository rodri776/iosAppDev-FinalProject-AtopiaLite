//
//  SimilarityService.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import Foundation
import Combine

/// Scores how similar two users are using a weighted mix of embedding cosine distance and label overlap.
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

    /// One user's similarity score and the breakdown of how it was computed.
    struct UserSimilarityResult: Identifiable {
        let user: LocalUser
        let similarity: Double
        let cosNorm: Double
        let textOverlap: Double
        let datapointsInCommon: [String]
        let percentageSimilarity: Int
        var id: String { user.id }
    }

    /// Ranks all other users against the current user and publishes sorted results.
    func computeSimilarities(currentUser: LocalUser, otherUsers: [LocalUser]) {
        isCalculating = true

        Task {
            if !embeddingManager.isReady {
                await embeddingManager.waitUntilReady()
            }

            let currentLabels = extractLabels(from: currentUser.savedDatapoints)
            let currentVectors = currentLabels.compactMap { embeddingManager.getEmbedding(for: $0) }
            let currentCentroid = embeddingManager.calculateCentroid(vectors: currentVectors)
            let currentLabelSet = Set(currentLabels)

            var computed: [UserSimilarityResult] = []

            for other in otherUsers {
                let otherLabels = extractLabels(from: other.savedDatapoints)
                let otherLabelSet = Set(otherLabels)

                // 1. Centroid cosine similarity, normalized to [0,1]
                let cosNorm: Double
                if let cc = currentCentroid {
                    let otherVectors = otherLabels.compactMap { embeddingManager.getEmbedding(for: $0) }
                    if let oc = embeddingManager.calculateCentroid(vectors: otherVectors) {
                        let raw = embeddingManager.cosineSimilarity(cc, oc)
                        cosNorm = (raw + 1.0) / 2.0
                    } else {
                        cosNorm = 0.0
                    }
                } else {
                    cosNorm = 0.0
                }

                // 2. Dice–Sørensen coefficient on datapoint labels
                let textOverlap = diceCoefficient(currentLabelSet, otherLabelSet)

                let score = 0.40 * cosNorm + 0.60 * textOverlap

                let commonLabels = Array(currentLabelSet.intersection(otherLabelSet)).sorted()

                computed.append(UserSimilarityResult(
                    user: other,
                    similarity: score,
                    cosNorm: cosNorm,
                    textOverlap: textOverlap,
                    datapointsInCommon: commonLabels,
                    percentageSimilarity: Int(score * 100)
                ))
            }

            results = computed.sorted { $0.similarity > $1.similarity }
            isCalculating = false
        }
    }

    /// Dice–Sørensen coefficient: 2|A∩B| / (|A|+|B|)
    private func diceCoefficient(_ a: Set<String>, _ b: Set<String>) -> Double {
        let total = a.count + b.count
        guard total > 0 else { return 0.0 }
        return (2.0 * Double(a.intersection(b).count)) / Double(total)
    }

    private func extractLabels(from paths: [String]) -> [String] {
        paths.compactMap { $0.components(separatedBy: UserProfileManager.pathSeparator).last }
    }
}
