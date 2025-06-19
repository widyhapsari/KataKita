//
//  GuideView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: WelcomeViewModel = WelcomeViewModel()
    
    var body: some View {
        switch viewModel.state {
        case .loading:
            LoadingView()
        case .loaded:
            ZStack {
                Rectangle()
                    .foregroundStyle(Color("B1E5FD"))
                    .ignoresSafeArea()
                
                VStack {
                    Welcome()
                    
                    LessonPreview()
                        .environmentObject(viewModel)
                }
            }
            .navigationBarBackButtonHidden(true)
        case .error(let error):
            ErrorView(error: error, onRetry: {
                print("Button pressed!")
            })
        }
    }
}

#Preview {
    WelcomeView()
}
