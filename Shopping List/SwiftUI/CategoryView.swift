//
//  CategoryView.swift
//  Shopping List
//
//  Created by Pavlo Moroz on 2024-03-27.
//  Copyright © 2024 Pavel Moroz. All rights reserved.
//

import SwiftUI
import SwiftData


struct CategoryView: View {
    
    @AppStorage("sessionCount") private var sessionCount: Int = 0
    
    var body: some View {
        ContentView()
    }
}


struct ContentView: View {
    @State private var searchText = ""
    @State private var showAlert = false
    
    @Query private var categories: [Category] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(filteredCategories) { category in
                    VStack(alignment: .leading) {
                        Text(category.name)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                    ToolbarItem {
                        Button(action: {
                            showAlert = true // Показываем алерт при нажатии на кнопку "+"
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }
                }
        }
        .searchable(text: $searchText)
        .alert(isPresented: $showAlert) { // Отображаем алерт, когда showAlert равно true
            Alert(title: Text("Title"), message: Text("Message"), primaryButton: .default(Text("Add")) {
                // Действие при нажатии кнопки "Add"
                // Добавьте вашу логику здесь
            }, secondaryButton: .destructive(Text("Cancel")))
        }
    }
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}


#Preview {
    CategoryView()
}



