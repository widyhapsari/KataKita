//
//  VoiceRecorder.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct VoiceRecorder: View {
    var speechManager: speechRecognitionManager
    var viewModel: QuizViewModel
    
    var body: some View {
        VStack {
            Button {
                speechManager.startRecording()
            } label: {
                Image(systemName: "microphone")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .padding()
                    .background(.black)
                    .cornerRadius(.infinity)
            }
            .disabled(!speechManager.hasPermission)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.gray.opacity(0.1))
    }
}

#Preview {
//    VoiceRecorder
}
