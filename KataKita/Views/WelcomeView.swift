//
//  GuideView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Welcome()
            
            LessonPreview()
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cyan)
    }
}

#Preview {
    WelcomeView()
}
