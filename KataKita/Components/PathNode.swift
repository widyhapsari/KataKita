//
//  LessonView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct PathNode: View {
    var isLocked: Bool = false
    var title: String? = nil
    var align: Alignment

    var body: some View {
        NavigationLink {
            VStack {
                WelcomeView()
            }
        } label: {
            VStack {
                ZStack {
                    Circle()
                        .strokeBorder(Color.gray, lineWidth: 6)
                        .frame(width: 100, height: 100)
                        .background(Circle().fill(Color.white))

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 40))
                    }
                }

                if let title = title {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .frame(width: 120)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: align)
        }

    }
}

#Preview {
    PathNode(align: .center)
        .padding()
}

//struct CourseLesson
