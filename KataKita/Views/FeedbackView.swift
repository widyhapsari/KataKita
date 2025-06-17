//
//  FeedbackView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct FeedbackView: View {
    var body: some View {
        VStack {
            Welcome()
            
            Feedback()
        }
        .padding()
        .background(.gray.opacity(0.2))
    }
}

#Preview {
    NavigationStack {
        FeedbackView()
    }
}
