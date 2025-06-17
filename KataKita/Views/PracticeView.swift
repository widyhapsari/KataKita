//
//  PracticeView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct PracticeView: View {
    var value: Double {
        return 1/3
    }
    
    var body: some View {
        VStack {
            ProgressView(value: value)
                .padding()
            
            HStack {
                Spacer()
                
                ConversationBox()
            }
            
            Spacer()
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        
        VStack {
            WordNodes()
            
            VoiceRecorder()
        }
    }
}

#Preview {
    PracticeView()
}
