//
//  RecommendationCoordinator.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/23/26.
//

import Foundation

/// Takes the user's saved datapoints, computes a centroid embedding, and finds the closest unsaved items.
@MainActor
class RecommendationCoordinator {
    private let embeddingManager: EmbeddingManager
    
    init(embeddingManager: EmbeddingManager) {
        self.embeddingManager = embeddingManager
    }
    
    /// Returns up to 5 recommended datapoints based on embedding similarity to what the user has saved.
    func generateRecommendations(
        savedDatapointPaths: Set<String>,
        allDataItems: [DataItem]
    ) -> Result<[ClusterRecommendation], RecommendationError> {
        print("[Recommendations] Generating: \(savedDatapointPaths.count) saved datapoints, \(allDataItems.count) total items")
        guard savedDatapointPaths.count >= 4 else {
            print("[Recommendations] Insufficient data: need 4, have \(savedDatapointPaths.count)")
            return .failure(.insufficientData)
        }
        
        let savedLabels = savedDatapointPaths.compactMap { path -> String? in
            path.components(separatedBy: UserProfileManager.pathSeparator).last
        }
        print("[Recommendations] Extracted \(savedLabels.count) labels from paths")
        
        let savedVectors = savedLabels.compactMap { label in
            embeddingManager.getEmbedding(for: label)
        }
        print("[Recommendations] Got \(savedVectors.count) embedding vectors from \(savedLabels.count) labels")
        
        let minimumRequired = max(1, savedLabels.count / 3)
        guard savedVectors.count >= minimumRequired else {
            print("[Recommendations] Not enough embeddings: need \(minimumRequired), have \(savedVectors.count)")
            return .failure(.embeddingsNotFound)
        }
        
        guard let centroid = embeddingManager.calculateCentroid(vectors: savedVectors) else {
            print("[Recommendations] Failed to calculate centroid")
            return .failure(.centroidCalculationFailed)
        }
        print("[Recommendations] Centroid calculated (dim=\(centroid.count))")
        
        let candidates: [(label: String, vector: [Double])] = allDataItems.compactMap { item in
            let path = datapointPath(
                category: item.category,
                subcategory: item.subcategory ?? "general",
                subSubcategory: item.sub_subcategory,
                label: item.label
            )
            
            guard !savedDatapointPaths.contains(path) else { return nil }
            guard let vector = embeddingManager.getEmbedding(for: item.label) else { return nil }
            
            return (label: item.label, vector: vector)
        }
        
        let topLabels = embeddingManager.findMostSimilar(
            to: centroid,
            from: candidates,
            limit: 5
        )
        
        let results: [ClusterRecommendation] = topLabels.compactMap { label in
            guard let dataItem = allDataItems.first(where: { $0.label == label }) else {
                return nil
            }
            return ClusterRecommendation(
                label: label,
                category: dataItem.category,
                subcategory: dataItem.subcategory ?? "general",
                subSubcategory: dataItem.sub_subcategory
            )
        }
        
        print("[Recommendations] Generated \(results.count) recommendations: \(results.map { $0.label })")
        return .success(results)
    }
    
    private func datapointPath(category: String, subcategory: String, subSubcategory: String?, label: String) -> String {
        var components: [String] = [category, subcategory]
        if let subSub = subSubcategory {
            components.append(subSub)
        }
        components.append(label)
        return components.joined(separator: UserProfileManager.pathSeparator)
    }
}

/// One recommended datapoint with its full category path.
struct ClusterRecommendation {
    let label: String
    let category: String
    let subcategory: String
    let subSubcategory: String?
}

/// Reasons recommendation generation can fail.
enum RecommendationError: Error {
    case insufficientData
    case embeddingsNotFound
    case centroidCalculationFailed
    
    var localizedDescription: String {
        switch self {
        case .insufficientData:
            return "Need at least 4 saved datapoints"
        case .embeddingsNotFound:
            return "Unable to generate recommendations"
        case .centroidCalculationFailed:
            return "Unable to calculate preferences"
        }
    }
}
