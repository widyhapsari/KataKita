//
//  FeedbackView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct FeedbackView: View {
    var feedbackType: FeedbackType
    
    var body: some View {
        ZStack {
            Image(feedbackType.backgroundImage)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 120)
                
                ZStack {
                    Image(feedbackType.mascotImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 250)
                        .offset(y:60)
                    
                    VStack {
                        Text(feedbackType.speechTop)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Spacer().frame(height:15)
                        Text(feedbackType.speechMiddle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer().frame(height:15)
                        Text(feedbackType.speechBottom)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .frame(width: 235)
                    .background(Color.white)
                    .cornerRadius(12)
                    .offset(x: 70, y: -140)
                }
                
                // Main feedback card (component)
                Feedback(feedbackType: .negative)
                    .padding(.horizontal, -8)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                HStack {
                    Button(action: { /* retry action */ }) {
                        Image("retry")
                    }
                    Spacer() .frame(width: 30)
                    Button(action: { /* home action */ }) {
                        Image("home")
                    }
                }
            }
            .padding()
        }
    }
}


#Preview {
    NavigationStack {
        FeedbackView(feedbackType: .negative)
    }
}
