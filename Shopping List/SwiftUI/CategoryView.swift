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
    @State private var searchText = ""
    @State private var showAddAlert = false
    @State private var textFieldInput = ""
    
    @Query private var categories: [Category]
    
    @Environment(\.modelContext) var context
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(filteredCategories) { category in
                    HStack {
                        VStack(alignment: .leading) {
                            Image("default")
                                .resizable()
                                .frame(width: 50, height: 50)
                            VStack {
                                Text(category.name)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showAddAlert = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .alert(Text(LocalizedStrings.alertAddButtonTitle), isPresented: $showAddAlert) {
            TextField("", text: $textFieldInput)
            HStack {
                Button(action: {
                    textFieldInput = ""
                }, label: {
                    Text("Close")
                        .foregroundColor(Color.red)
                })
                
                .foregroundStyle(Color.red)
                Button("Save",action: {
                    let category = Category(name: textFieldInput)
                    context.insert(category)
                    textFieldInput = ""
                })
            }
        } message: {
            Text(LocalizedStrings.alertAddButtonMessage)
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

extension CategoryView {
    
    struct LocalizedStrings {
        
        static let alertAddButtonTitle = NSLocalizedString("AddingCategory", comment: "")
        static let alertAddButtonMessage = NSLocalizedString("EnterName", comment: "")
    }
}


#Preview {
    CategoryView()
}



