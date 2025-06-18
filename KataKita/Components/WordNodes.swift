//
//  WordNodes.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 16/06/25.
//

import SwiftUI

struct WordSet {
    let romaji: [String]
    let nihongo: [String]
    let english: String
}

// Sample data
let wordSets: [WordSet] = [
    WordSet(
        romaji: ["Sumimasen", "niku", "chaahan", "wa", "ebi", "toka", "kani", "haitte", "imasu", "ka?"],
        nihongo: ["すみません", "この", "チャーハン", "は", "エビ", "とか", "カニ", "入って", "います", "か"],
        english: "🇬🇧: “Excuse me, does this contain meat?”"
    ),
    WordSet(
        romaji: ["Arigatou", "gozaimasu.", "Ebi", "nuki", "tte", "dekimasu", "ka?"],
        nihongo: ["ありがとう", "ございます.", "エビ", "抜き", "って", "できます", "か?"],
        english: "🇬🇧: “Excuse me, does this food contain pork and alcohol?”"
    )
]

struct WordNodes: View {
    @StateObject private var speechManager = speechRecognitionManager()
    @StateObject private var viewModel = QuizViewModel()
    @State private var showButton = true
    @Binding var nextButton: Bool
    @State private var step = 0

    var currentSet: WordSet {
        wordSets[min(step, wordSets.count - 1)]
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Ask this to the staff:")
                .font(.callout)

            // Split words into two rows
            let midIndex = currentSet.romaji.count * 2 / 4
            let firstRow = zip(
                currentSet.romaji.prefix(midIndex),
                currentSet.nihongo.prefix(midIndex)
            )
            let secondRow = zip(
                currentSet.romaji.suffix(from: midIndex),
                currentSet.nihongo.suffix(from: midIndex)
            )

            HStack(spacing: 24) {
                ForEach(Array(firstRow), id: \.1) { romaji, nihongo in
                    let cleanNihongo = nihongo.trimmingCharacters(in: .punctuationCharacters)
                    wordCard(
                        romaji: romaji,
                        nihongo: nihongo,
                        status: viewModel.wordStatuses[cleanNihongo] ?? .neutral
                    )
                }
            }

            HStack(spacing: 24) {
                ForEach(Array(secondRow), id: \.1) { romaji, nihongo in
                    let cleanNihongo = nihongo.trimmingCharacters(in: .punctuationCharacters)
                    wordCard(
                        romaji: romaji,
                        nihongo: nihongo,
                        status: viewModel.wordStatuses[cleanNihongo] ?? .neutral
                    )
                }

            }

            Text(currentSet.english)
                .font(.footnote)
                .foregroundStyle(.gray)

            if showButton {
                Button(action: {
                    if speechManager.isRecording {
                        speechManager.stopRecording()
                        showButton = false
                    } else {
                        viewModel.resetStatuses()
                        speechManager.setCurrentWordSet(currentSet)
                        speechManager.startRecording()
                    }
                }) {
                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(speechManager.isRecording ? .red : Color("04B3AC"))
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
                .disabled(!speechManager.hasPermission)
            } else {
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
            }

            if speechManager.overallScore < 0.8 && !showButton {
                Button(action: {
                    showButton = true
                }) {
                    Text("Retry")
                        .font(.title2)
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
                .frame(maxWidth: .infinity, maxHeight: 80)
            }
        }
        .padding()
        .onReceive(speechManager.$recognizedText) { text in
            viewModel.updateStatuses(from: text)
        }
        .onReceive(speechManager.$pronunciationScores) { scores in
            viewModel.updateScores(from: scores)
        }
        .onChange(of: speechManager.overallScore) { newScore in
            if newScore >= 0.8 && !showButton {
                showButton = false
                nextButton = true
            }
        }
            .disabled(step >= wordSets.count - 1)
    }
}

#Preview {
    WordNodes(nextButton: .constant(false))
}

struct wordCard: View {
    var romaji: String = ""
    var nihongo: String = ""
    var status: WordStatus = .neutral

    var borderColor: Color {
        switch status {
        case .excellent: return .green
        case .good: return .green
        case .bad: return .green
        case .neutral: return .gray
        }
    }
     
    var body: some View {
        VStack(spacing: 10) {
            Text(romaji)
                .font(.callout)
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
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .background(.white)
        .cornerRadius(12)
        .scaleEffect(status == .excellent ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: status)
    }
}

