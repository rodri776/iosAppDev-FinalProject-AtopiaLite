//
//  UserProfileManager.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/23/26.
//

import Foundation
import Combine
import CoreGraphics

class UserProfileManager: ObservableObject {
    @Published var savedDatapoints: Set<String> = []
    
    let userId: String
    private var savedDatapointsKey: String { "AtopiaLite.savedDatapoints.\(userId)" }
    
    init(userId: String = "default") {
        self.userId = userId
        load()
    }
    
    /// Extract just the labels from saved datapoint paths
    var savedDatapointLabels: [String] {
        savedDatapoints.compactMap { $0.components(separatedBy: "/").last }
    }
    
    var savedDatapointsCount: Int {
        savedDatapoints.count
    }
    
    var canShowRecommendations: Bool {
        savedDatapoints.count >= 4
    }
    
    func saveDatapoint(_ path: String) {
        savedDatapoints.insert(path)
        persist()
    }
    
    func removeDatapoint(_ path: String) {
        savedDatapoints.remove(path)
        persist()
    }
    
    func isDatapointSaved(_ path: String) -> Bool {
        savedDatapoints.contains(path)
    }
    
    func getSavedDatapointsByCategory(
        allDataItems: [DataItem]
    ) -> [SavedCategory] {
        var categories: [String: [SavedDatapoint]] = [:]
        
        for path in savedDatapoints {
            let components = path.components(separatedBy: "/")
            guard components.count >= 3, let label = components.last else { continue }
            
            let category = components[0]
            let subcategory = components[1]
            let subSubcategory = components.count > 3 ? components[2] : nil
            
            let tempNode = Node(
                position: .zero,
                label: category,
                type: .category
            )
            
            let datapoint = SavedDatapoint(
                label: label,
                category: category,
                subcategory: subcategory,
                subSubcategory: subSubcategory,
                categoryColor: tempNode.color
            )
            
            categories[category, default: []].append(datapoint)
        }
        
        return categories.map { category, datapoints in
            let tempNode = Node(
                position: .zero,
                label: category,
                type: .category
            )
            
            return SavedCategory(
                name: category,
                color: tempNode.color,
                datapoints: datapoints.sorted { $0.label < $1.label }
            )
        }.sorted { $0.name < $1.name }
    }
    
    private func load() {
        if let datapointsArray = UserDefaults.standard.array(forKey: savedDatapointsKey) as? [String] {
            savedDatapoints = Set(datapointsArray)
        }
    }
    
    private func persist() {
        let datapointsArray = Array(savedDatapoints)
        UserDefaults.standard.set(datapointsArray, forKey: savedDatapointsKey)
    }
    
    func datapointPath(category: String?, subcategory: String?, subSubcategory: String?, label: String) -> String {
        var components: [String] = []
        if let cat = category { components.append(cat) }
        if let sub = subcategory { components.append(sub) }
        if let subSub = subSubcategory { components.append(subSub) }
        components.append(label)
        return components.joined(separator: "/")
    }
}
