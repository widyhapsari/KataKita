//
//  ScenarioView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct ScenarioView: View {
//<<<<<<< HEAD
    @ObservedObject var viewModel: ScenarioViewModel = ScenarioViewModel()
    @State private var currentPage: Int = 1
    
    var value: Double {
        return 3/5
    }
    
    var body: some View {
        ZStack {
            Image("road")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Image("restaurant")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    Image("waiter")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                
                Guide(currentPage: $currentPage, overallPages: 3)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Conversation 1")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    WelcomeView()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .font(.callout)
                        .foregroundStyle(.black)
                        .bold()
                }

            }
        }
    }
}

struct CustomProgressView: View {
    var value: CGFloat // 0.0 to 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .cornerRadius(12)

                Rectangle()
                    .fill(Color("04B3AC"))
                    .frame(width: geometry.size.width * value, height: 16)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(height: 16)
    }
}

#Preview {
    NavigationStack {
        ScenarioView()
    }
}
