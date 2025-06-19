//
//  FeedbackView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct FeedbackView: View {
    var score: Double
    
    var feedbackType: FeedbackType {
        feedbackType(for: score)
    }
    
    func feedbackType(for score: Double) -> FeedbackType {
        return score >= 0.8 ? .positive : .negative
    }
    
    var body: some View {
        ZStack {
            Image(feedbackType.backgroundImage)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 100)
                
                ZStack {
                    Image(feedbackType.mascotImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                        .offset(y:48)
                    
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
                    .offset(x: 70, y: -100)
                }
                
                // Main feedback card (component)
                Feedback(feedbackType: .positive)
                    .padding(.horizontal, -8)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer() .frame(height: 10)
                HStack {
                    NavigationLink {
//                        PracticeView(nextButton: false)
                    } label: {
                        Text("RETRY")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .background(
                                Image("signSecondary")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 60)
                            )
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        WelcomeView()
                    } label: {
                        Text("HOME")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .background(
                                Image("sign")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 60)
                            )
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}


//#Preview {
//    NavigationStack {
//        FeedbackView(feedbackType: )
//    }
//}
