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
        VStack(spacing: 32) {
            // Title
            Text("Say: Arigatou gozaimasu")
                .font(.title2)
                .padding()
            
            // Overall Score Display
            if speechManager.overallScore > 0 {
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
            
            // Word cards with individual scores
            HStack(spacing: 16) {
                wordCard(
                    romaji: "Arigatou",
                    nihongo: "ありがとう",
                    status: viewModel.wordStatuses["ありがとう"] ?? .neutral,
                    score: speechManager.pronunciationScores["ありがとう"] ?? 0.0
                )
                
                wordCard(
                    romaji: "gozaimasu",
                    nihongo: "ございます",
                    status: viewModel.wordStatuses["ございます"] ?? .neutral,
                    score: speechManager.pronunciationScores["ございます"] ?? 0.0
                )
            }
            
            // Recording button
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
                        .foregroundColor(speechManager.isRecording ? .red : .blue)
                    
                    Text(speechManager.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.headline)
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
            
            Spacer()
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
    QuizView()
}

struct wordCard: View {
    var romaji: String = ""
    var nihongo: String = ""
    var status: WordStatus = .neutral
    var score: Double = 0.0

    var borderColor: Color {
        switch status {
        case .excellent: return .green
        case .good: return .orange
        case .bad: return .red
        case .neutral: return .gray
        }
    }
    
//    var backgroundColor: Color {
//        switch status {
//        case .correct: return .green.opacity(0.1)
//        case .incorrect: return .red.opacity(0.1)
//        case .neutral: return .white
//        }
//    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(romaji)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
            Text(nihongo)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            // Individual score display
            if score > 0 {
                HStack(spacing: 4) {
                    Image(systemName: score >= 0.7 ? "checkmark.circle.fill" :
                                    score >= 0.5 ? "exclamationmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(score >= 0.7 ? .green : score >= 0.5 ? .orange : .red)
                        .font(.caption)
                    
                    Text("\(Int(score * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(score >= 0.7 ? .green : score >= 0.5 ? .orange : .red)
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 2)
                .animation(.easeInOut(duration: 0.3), value: status)
        )
        .cornerRadius(12)
        .scaleEffect(status == .excellent ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: status)
    }
}
