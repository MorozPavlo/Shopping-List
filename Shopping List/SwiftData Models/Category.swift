//
//  Category.swift
//  Shopping List
//
//  Created by Pavlo Moroz on 2024-03-27.
//  Copyright © 2024 Pavel Moroz. All rights reserved.
//
//

import Foundation
import SwiftData


@Model public class Category {
    var name: String
    var order: Int32? = 0
    var items: [List]?
    public init(name: String) {
        self.name = name

    }
    
}
