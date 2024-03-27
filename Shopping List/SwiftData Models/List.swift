//
//  List.swift
//  Shopping List
//
//  Created by Pavlo Moroz on 2024-03-27.
//  Copyright © 2024 Pavel Moroz. All rights reserved.
//
//

import Foundation
import SwiftData


@Model public class List {
    var cost: Double? = 0.0
    var isBuy: Bool?
    var name: String?
    var order: Int32? = 0
    var parentCategory: Category?
    public init() {

    }
    
}
