//
//  EmbeddingManager.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/22/26.
//

import Foundation
import NaturalLanguage

/// Wraps Apple's NLEmbedding to produce, cache, and compare sentence vectors.
@MainActor
class EmbeddingManager {
    private var embeddingCache: [String: [Double]] = [:]
    private var embedding: NLEmbedding?
    var isReady = false
    private var loadingTask: Task<Void, Never>?
    
    init() {
        print("[Embedding] Initializing EmbeddingManager, loading NLEmbedding model")
        loadingTask = Task {
            let model = NLEmbedding.sentenceEmbedding(for: .english)
            self.embedding = model
            self.isReady = (model != nil)
            print("[Embedding] NLEmbedding model loaded: \(model != nil ? "available" : "nil"), isReady=\(self.isReady)")
        }
    }
    
    /// Warms the cache by embedding every label in the dataset up front.
    func preEmbed(labels: [String]) {
        print("[Embedding] Pre-embedding \(labels.count) labels")
        Task {
            await loadingTask?.value
            for label in labels {
                _ = getEmbedding(for: label)
            }
            print("[Embedding] Pre-embedding complete, cache size: \(embeddingCache.count)")
        }
    }
    
    func embedEagerly(_ label: String) {
        _ = getEmbedding(for: label)
    }
    
    func waitUntilReady() async {
        await loadingTask?.value
    }
    
    /// Returns the cached vector for a label, or computes and caches it. Falls back to averaging individual word vectors.
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
    
    /// Averages a set of vectors into a single centroid.
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
    
    /// Cosine similarity between two vectors, in range [-1, 1].
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
    
    /// Returns the top N candidate labels closest to the target vector by cosine similarity.
    func findMostSimilar(
        to targetVector: [Double],
        from candidates: [(label: String, vector: [Double])],
        limit: Int
    ) -> [String] {
        print("[Embedding] Finding most similar: \(candidates.count) candidates, limit=\(limit)")
        var scored: [(label: String, similarity: Double)] = []
        
        for candidate in candidates {
            let similarity = cosineSimilarity(targetVector, candidate.vector)
            scored.append((label: candidate.label, similarity: similarity))
        }
        
        let sorted = scored.sorted { $0.similarity > $1.similarity }
        let results = Array(sorted.prefix(limit).map { $0.label })
        print("[Embedding] Top \(results.count) similar: \(results)")
        return results
    }
}
