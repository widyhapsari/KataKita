//
//  CourseView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct CourseView: View {    
    var body: some View {
        Welcome()
        
        // Path nodes
        ScrollView {
            VStack {
                ForEach(Array(pathItems.enumerated().reversed()), id: \.element.id) { index, item in
                    HStack {
                        if index % 2 == 0 {
                            PathNode(isLocked: item.isLocked, title: item.title, align: .leading)
                        } else {
                            PathNode(isLocked: item.isLocked, title: item.title, align: .trailing)
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationStack {
        CourseView()
    }
}
