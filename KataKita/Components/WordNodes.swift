//
//  WordNodes.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct WordNodes: View {
    @StateObject private var speechManager = speechRecognitionManager()
    @StateObject private var viewModel = QuizViewModel()
    @State private var showButton = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Word cards with individual scores
            VStack(spacing: 20) {
                // Title
                Text("Ask this to the staff:")
                    .font(.title3)
//                    .foregroundStyle(Color.gray)
                
                HStack(spacing: 24) {
                    wordCard(
                        romaji: "Arigatou",
                        nihongo: "ありがとう",
                        status: viewModel.wordStatuses["ありがとう"] ?? .neutral
                    )
                    
                    wordCard(
                        romaji: "gozaimasu.",
                        nihongo: "ございます.",
                        status: viewModel.wordStatuses["ございます"] ?? .neutral
                    )
                    
                    wordCard(
                        romaji: "Ebi",
                        nihongo: "エビ",
                        status: viewModel.wordStatuses["エビ"] ?? .neutral
                    )
                }
                
                HStack(spacing: 24) {
                    wordCard(
                        romaji: "nuki",
                        nihongo: "抜き",
                        status: viewModel.wordStatuses["抜き"] ?? .neutral
                    )
                    
                    wordCard(
                        romaji: "tte",
                        nihongo: "って",
                        status: viewModel.wordStatuses["って"] ?? .neutral
                    )
                    
                    wordCard(
                        romaji: "dekimasu",
                        nihongo: "できます",
                        status: viewModel.wordStatuses["できます"] ?? .neutral
                    )
                    
                    wordCard(
                        romaji: "ka?",
                        nihongo: "か?",
                        status: viewModel.wordStatuses["か"] ?? .neutral
                    )
                }

            }
            
            Text("🇬🇧: “Excuse me, does this food contain pork and alcohol?”")
                .font(.footnote)
                .foregroundStyle(.gray)
            
            // Recording button
            if showButton {
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
            }
            
            if speechManager.overallScore >= 0.8 {
                VStack(spacing: 8) {
                    Text("Overall Score")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)

                        Circle()
                            .trim(from: 0, to: speechManager.overallScore)
                            .stroke(
                                speechManager.overallScore >= 0.7 ? Color.green :
                                speechManager.overallScore >= 0.5 ? Color.orange : Color.red,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: speechManager.overallScore)

                        Text("\(Int(speechManager.overallScore * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()
            }
        }
        .padding()
        .onReceive(speechManager.$recognizedText) { text in
            viewModel.updateStatuses(from: text)
        }
        .onReceive(speechManager.$pronunciationScores) { scores in
            viewModel.updateScores(from: scores)
        }
    }
}

#Preview {
    WordNodes()
}

struct wordCard: View {
    var romaji: String = ""
    var nihongo: String = ""
    var status: WordStatus = .neutral

    var borderColor: Color {
        switch status {
        case .excellent: return .green
        case .good: return .orange
        case .bad: return .red
        case .neutral: return .gray
        }
    }
     
    var body: some View {
        VStack(spacing: 10) {
            Text(romaji)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(borderColor)
                .background(
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: geometry.size.width + 2, height: 2)
                            .position(x: geometry.size.width / 2, y: geometry.size.height + 4)
                    }
                )
                
            Text(nihongo)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)
        }
        .background(.white)
        .cornerRadius(12)
        .scaleEffect(status == .excellent ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: status)
    }
}

