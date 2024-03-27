//
//  Category.swift
//  Shopping List
//
//  Created by Admin on 30/11/2022.
//  Copyright © 2022 Pavel Moroz. All rights reserved.
//

import UIKit

struct CategoryItem: Hashable, Decodable {
    var nameCategory: String
    var categoryImage: String
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CategoryItem, rhs: CategoryItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        
        let lowercaseFilter = filter.lowercased()
        
        return nameCategory.lowercased().contains(lowercaseFilter)
    }
}

extension CategoryItem {
    
    init(categoryStorage: Category) {
        self.nameCategory = categoryStorage.name ?? ""
        
        self.id = Int(categoryStorage.order ?? 23) + 1
        self.categoryImage = ""
    }
}
