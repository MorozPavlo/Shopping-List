//
//  MainView.swift
//  Shopping List
//
//  Created by Pavlo Moroz on 2024-03-27.
//  Copyright © 2024 Pavel Moroz. All rights reserved.
//

import SwiftUI
import SwiftData

struct MainView: View {
    var body: some View {
        CategoryView()
        .modelContainer(
            for: [List.self, Category.self]
        )
    }
}
