//
//  TestView.swift
//  Shopping List
//
//  Created by Pavlo Moroz on 2024-03-28.
//  Copyright © 2024 Pavel Moroz. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ScrollView {
            Section(header: Text("Section 1").font(.title)) {
                ForEach(0...10, id: \.self) { index in
                    VStack {
                        Rectangle()
                            .frame(width: 150, height: 150)
                            .foregroundStyle(Color.random)
                        Text("fafawfawffawfawffawfwafawfwafawfaw")
                    }
                }
            }
            
            Section(header: Text("Section 2").font(.title)) {
                ForEach(11...20, id: \.self) { index in
                    Rectangle()
                        .frame(width: 75, height: 75)
                        .foregroundStyle(Color.random)
                }
            }
        }
    }
}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

#Preview {
    ContentView()
}
