//
//  QuizView.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 03/06/25.
//


import SwiftUI

struct QuizView: View {
    @StateObject private var speechManager = speechRecognitionManager()
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        VStack {
            Button(action: {
                speechManager.startRecording()
            }) {
                VStack(spacing: 24) {
                    HStack {
                        wordCard(
                            romaji: "Arigatou",
                            nihongo: "ありがとう",
                            status: viewModel.wordStatuses["ありがとう"] ?? .neutral
                        )
                        
                        wordCard(
                            romaji: "gozaimasu",
                            nihongo: "ございます",
                            status: viewModel.wordStatuses["ございます"] ?? .neutral
                        )
                    }
                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 56))
                }
            }
            .disabled(!speechManager.hasPermission)
            
            NavigationLink {
                Feedback()
            } label: {
                VStack {
                    Text("Feedback")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(12)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
            }

        }
        .onReceive(speechManager.$recognizedText) { text in
            viewModel.updateStatuses(from: text)
        }
    }
}

#Preview {
    QuizView()
}

//struct PracticeView: View {
//    
//    var value: Double {
//        return 1/3
//    }
//    
//    var body: some View {
//        VStack {
//            ProgressView(value: value)
//                .padding()
//            
//            HStack {
//                Spacer()
//                
//                ConversationBox()
//            }
//            
//            Spacer()
//            
//        }
//        .padding()
//        .background(Color.gray.opacity(0.1))
//        
//        VStack {
//            WordNodes()
//            
//            VoiceRecorder()
//        }
//    }
//}

struct wordCard: View {
    var romaji: String = ""
    var nihongo: String = ""
    var status: WordStatus = .neutral

    var borderColor: Color {
        switch status {
        case .correct: return .green
        case .incorrect: return .red
        case .neutral: return .black
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text (romaji)
                .font(.system(size: 24))
                .foregroundColor(.black)
            Text (nihongo)
                .font(.system(size: 18))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 3)
                .animation(.easeInOut, value: status)
        )
        .cornerRadius(12)
    }
}
