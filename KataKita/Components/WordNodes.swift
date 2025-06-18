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
        romaji: ["Arigatou", "gozaimasu.", "Ebi", "nuki", "tte", "dekimasu", "ka?"],
        nihongo: ["ありがとう", "ございます.", "エビ", "抜き", "って", "できます", "か?"],
        english: "🇬🇧: “Excuse me, does this food contain pork and alcohol?”"
    ),
    WordSet(
        romaji: ["Sumimasen", "niku", "wa", "haitte", "imasu", "ka?"],
        nihongo: ["すみません", "肉", "は", "入って", "います", "か？"],
        english: "🇬🇧: “Excuse me, does this contain meat?”"
    )
]

struct WordNodes: View {
    @StateObject private var speechManager = speechRecognitionManager()
    @StateObject private var viewModel = QuizViewModel()
    @State private var showButton = true
    @State private var nextButton = true
    @State private var step = 0

    var currentSet: WordSet {
        wordSets[min(step, wordSets.count - 1)]
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Ask this to the staff:")
                .font(.callout)

            // Split words into two rows
            let midIndex = currentSet.romaji.count * 3 / 4
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
                        speechManager.startRecording()
                    }
                }) {
                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(speechManager.isRecording ? .red : Color("04B3AC"))
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
                .disabled(!speechManager.hasPermission)
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
            } else if speechManager.overallScore >= 0.8 && !showButton {
                Button(action: {
                    step += 1
                    showButton = true
                }) {
                    Text("Next")
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
                .disabled(step >= wordSets.count - 1)
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
//        .cornerRadius(12)
        .scaleEffect(status == .excellent ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: status)
    }
}

