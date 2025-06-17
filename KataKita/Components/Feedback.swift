//
//  Feedback.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct Feedback: View {
    @State private var progress = 0.6
    
    var body: some View {
        VStack {
            VStack {
                Text("Here’s your result...")
                    .font(.title3)
                
                ProgressView(value: progress) {
                    Text("Speaking Accuracy")
                        .font(.body)
                }
                .progressViewStyle(.circular)
                
                Text("This score is powered by machine learning. It’s helpful to track your progress, but not always 100% accurate.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
                
                HStack {
                    NavigationLink {
                        ScenarioView()
                    } label: {
                        VStack {
                            Text("Retry")
                                .font(.body)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.cyan)
                                .cornerRadius(12)
                        }
                    }

                    NavigationLink {
                        CourseView()
                    } label: {
                        VStack {
                            Text("Home")
                                .font(.body)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.cyan)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Feedback()
}
