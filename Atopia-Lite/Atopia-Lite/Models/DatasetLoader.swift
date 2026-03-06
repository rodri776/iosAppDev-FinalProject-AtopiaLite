//
//  DatasetLoader.swift
//  MeMyselfAI
//
//  Created by Juniper Rodriguez on 2/16/26.
//

import Foundation

struct DatasetLoader {
    
    static func loadDataset() -> (items: [DataItem], hierarchy: [CategoryNode]) {
        let data = Data(datasetJSON.utf8)
        guard let dataItems = try? JSONDecoder().decode([DataItem].self, from: data) else {
            return ([], [])
        }
        
        var categoryMap: [String: CategoryNode] = [:]
        
        // Build the hierarchy by iterating through all items
        for item in dataItems {
            if categoryMap[item.category] == nil {
                categoryMap[item.category] = CategoryNode(name: item.category)
            }
            var category = categoryMap[item.category]!
            
            if let subcategoryIndex = category.subcategories.firstIndex(where: { $0.name == item.subcategory }) {
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
                var newSubcategory = SubcategoryNode(name: item.subcategory)
            
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
        
        return (dataItems, categoryHierarchy)
    }
}
