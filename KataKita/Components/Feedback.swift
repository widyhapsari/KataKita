//
//  Feedback.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct Feedback: View {
    var feedbackType: FeedbackType
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Conversation #1: Say Your Allergies")
                .font(.subheadline)
                .bold()
                .foregroundColor(.gray)
                .padding(.top, 5)
            
            Text(feedbackType.feedbackTitle)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            
            Text(feedbackType.feedbackSubtitle)
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}


#Preview {
    Feedback(feedbackType: .negative)
}
