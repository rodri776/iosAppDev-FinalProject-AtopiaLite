//
//  DatasetLoader.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/16/26.
//

import Foundation

/// Decodes the embedded JSON and builds the category/subcategory hierarchy.
struct DatasetLoader {
    
    /// Parses the bundled datapoints JSON and returns flat items plus a tree of categories.
    static func loadDataset() -> (items: [DataItem], hierarchy: [CategoryNode]) {
        print("[DatasetLoader] Loading dataset from embedded JSON (\(datasetJSON.count) characters)")
        let data = Data(datasetJSON.utf8)
        guard let dataItems = try? JSONDecoder().decode([DataItem].self, from: data) else {
            print("[DatasetLoader] ERROR: JSON decode failed — returning empty dataset")
            return ([], [])
        }
        print("[DatasetLoader] Decoded \(dataItems.count) DataItems")
        
        var categoryMap: [String: CategoryNode] = [:]
        
        for item in dataItems {
            if categoryMap[item.category] == nil {
                categoryMap[item.category] = CategoryNode(name: item.category)
            }
            var category = categoryMap[item.category]!
            let itemSubcategory = item.subcategory ?? "general"
            
            if let subcategoryIndex = category.subcategories.firstIndex(where: { $0.name == itemSubcategory }) {
                var subcategory = category.subcategories[subcategoryIndex]
                
                if let subSubcategoryName = item.sub_subcategory {
                    if let subSubcategoryIndex = subcategory.subSubcategories.firstIndex(where: { $0.name == subSubcategoryName }) {
                        subcategory.subSubcategories[subSubcategoryIndex].items.append(item.label)
                    } else {
                        var newSubSubcategory = SubSubcategoryNode(name: subSubcategoryName)
                        newSubSubcategory.items.append(item.label)
                        subcategory.subSubcategories.append(newSubSubcategory)
                    }
                } else {
                    subcategory.items.append(item.label)
                }
                
                category.subcategories[subcategoryIndex] = subcategory
            } else {
                var newSubcategory = SubcategoryNode(name: itemSubcategory)
            
                if let subSubcategoryName = item.sub_subcategory {
                    var newSubSubcategory = SubSubcategoryNode(name: subSubcategoryName)
                    newSubSubcategory.items.append(item.label)
                    newSubcategory.subSubcategories.append(newSubSubcategory)
                } else {
                    newSubcategory.items.append(item.label)
                }
                category.subcategories.append(newSubcategory)
            }
            
            categoryMap[item.category] = category
        }
        
        let categoryHierarchy = Array(categoryMap.values).sorted { $0.name < $1.name }
        print("[DatasetLoader] Built hierarchy: \(categoryHierarchy.count) categories — \(categoryHierarchy.map { $0.name })")
        
        return (dataItems, categoryHierarchy)
    }
}
