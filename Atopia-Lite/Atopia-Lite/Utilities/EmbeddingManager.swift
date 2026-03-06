//
//  EmbeddingManager.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/22/26.
//

import Foundation
import NaturalLanguage

@MainActor
class EmbeddingManager {
    private var embeddingCache: [String: [Double]] = [:]
    private var embedding: NLEmbedding?
    var isReady = false
    private var loadingTask: Task<Void, Never>?
    
    init() {
        loadingTask = Task {
            let model = NLEmbedding.sentenceEmbedding(for: .english)
            self.embedding = model
            self.isReady = (model != nil)
        }
    }
    
    func preEmbed(labels: [String]) {
        Task {
            await loadingTask?.value
            for label in labels {
                _ = getEmbedding(for: label)
            }
        }
    }
    
    func embedEagerly(_ label: String) {
        _ = getEmbedding(for: label)
    }
    
    func waitUntilReady() async {
        await loadingTask?.value
    }
    
    func getEmbedding(for label: String) -> [Double]? {
        if let cached = embeddingCache[label] {
            return cached
        }
        
        guard let embedding = embedding else { return nil }
        
        if let vector = embedding.vector(for: label.lowercased()) {
            embeddingCache[label] = vector
            return vector
        }
        
        let words = label.lowercased().split(separator: " ").map(String.init)
        let wordVectors = words.compactMap { embedding.vector(for: $0) }
        guard let averaged = calculateCentroid(vectors: wordVectors) else { return nil }
        
        embeddingCache[label] = averaged
        return averaged
    }
    
    func calculateCentroid(vectors: [[Double]]) -> [Double]? {
        guard !vectors.isEmpty, let firstVector = vectors.first else { return nil }
        
        let dimension = firstVector.count
        var centroid = [Double](repeating: 0.0, count: dimension)
        
        for vector in vectors {
            guard vector.count == dimension else { continue }
            for i in 0..<dimension {
                centroid[i] += vector[i]
            }
        }
        
        for i in 0..<dimension {
            centroid[i] /= Double(vectors.count)
        }
        
        return centroid
    }
    
    func cosineSimilarity(_ vec1: [Double], _ vec2: [Double]) -> Double {
        guard vec1.count == vec2.count else { return 0.0 }
        
        var dotProduct = 0.0
        var magnitude1 = 0.0
        var magnitude2 = 0.0
        
        for i in 0..<vec1.count {
            dotProduct += vec1[i] * vec2[i]
            magnitude1 += vec1[i] * vec1[i]
            magnitude2 += vec2[i] * vec2[i]
        }
        
        let denominator = sqrt(magnitude1) * sqrt(magnitude2)
        guard denominator > 0 else { return 0.0 }
        
        return dotProduct / denominator
    }
    
    func findMostSimilar(
        to targetVector: [Double],
        from candidates: [(label: String, vector: [Double])],
        limit: Int
    ) -> [String] {
        var scored: [(label: String, similarity: Double)] = []
        
        for candidate in candidates {
            let similarity = cosineSimilarity(targetVector, candidate.vector)
            scored.append((label: candidate.label, similarity: similarity))
        }
        
        let sorted = scored.sorted { $0.similarity > $1.similarity }
        return Array(sorted.prefix(limit).map { $0.label })
    }
}
