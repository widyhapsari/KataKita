//
//  VoiceRecorder.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct VoiceRecorder: View {
    @State var isDisabled: Bool = true
    @StateObject private var speechManager = speechRecognitionManager()
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        VStack {
            Button(action: {
                if speechManager.isRecording {
                    speechManager.stopRecording()
                } else {
                    viewModel.resetStatuses()
                    speechManager.startRecording()
                }
            }) {
                VStack(spacing: 8) {
                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(speechManager.isRecording ? .red : Color("04B3AC"))
                }
            }
            .disabled(!speechManager.hasPermission)
            
            // Debug section (you can remove this in production)
            if !speechManager.recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recognized:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(speechManager.recognizedText)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .font(.caption)
                }
                .padding(.horizontal)
            }
            
            
            // Permission status
            if !speechManager.hasPermission {
                Text("Please grant microphone and speech recognition permissions")
                    .foregroundColor(.red)
                    .padding()
            }

            
//            label: {
//                if isDisabled {
//                    Image(systemName: "microphone.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundStyle(.gray.opacity(0.8))
//                        .frame(width: 30, height: 30)
//                        .padding()
//                        .background(.gray.opacity(0.2))
//                        .cornerRadius(.infinity)
//                } else {
//                    Image(systemName: "microphone")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundStyle(.white)
//                        .frame(width: 30, height: 30)
//                        .padding()
//                        .background(Color("04B3AC"))
//                        .cornerRadius(.infinity)
//                }
//            }
//            .disabled(isDisabled)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("F3F2F8"))
    }
}

#Preview {
    VoiceRecorder()
}

//
//  ScenarioView.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//
