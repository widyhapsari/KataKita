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
        romaji: ["Sumimasen", "niku", "chaahan", "wa", "butaniku", "toka", "arukoru", "haitte", "imasu", "ka?"],
        nihongo: ["すみません", "この", "チャーハン", "は", "豚肉", "とか", "アルコール", "入って", "います", "か"],
        english: "🇬🇧: Excuse me, does this fried rice have pork or alcohol in it?"
    ),
    WordSet(
        romaji: ["Arigatou", "gozaimasu.", "butaniku", "nuki", "tte", "dekimasu", "ka?"],
        nihongo: ["ありがとう", "ございます.", "豚肉", "抜き", "って", "できます", "か?"],
        english: "🇬🇧: Thank you. Can you leave the pork out?"
    )
]

struct WordNodes: View {
    @StateObject private var speechManager = speechRecognitionManager()
    @StateObject private var viewModel = QuizViewModel()
    @State private var showButton = true
    @Binding var nextButton: Bool
    @Binding var step: Int
    @Binding var score: Double
    
    private func handleScoreChange(_ newScore: Double) {
        print("📊 Overall score changed to: \(newScore), Step: \(step), Current nextButton: \(nextButton)")
        
        if newScore >= 0.8 {
            print("✅ Score is good! Setting nextButton = true")
            showButton = false
            nextButton = true
        } else {
            print("❌ Score too low: \(newScore)")
            showButton = false
            nextButton = false
        }
    }


    var currentSet: WordSet {
        switch step {
        case 1: return wordSets[0]
        case 3: return wordSets[1]
        default: return wordSets[0]
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Ask this to the staff:")
                .font(.callout)

            let wordPairs = zip(currentSet.romaji, currentSet.nihongo).map { ($0.0, $0.1.trimmingCharacters(in: .punctuationCharacters)) }
            let midIndex = wordPairs.count / 2
            let rows = [Array(wordPairs[..<midIndex]), Array(wordPairs[midIndex...])]

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 24) {
                    ForEach(row, id: \.1) { romaji, nihongo in
                        wordCard(
                            romaji: romaji,
                            nihongo: nihongo,
                            status: viewModel.wordStatuses[nihongo] ?? .neutral
                        )
                    }
                }
            }

            Text(currentSet.english)
                .font(.footnote)
                .foregroundStyle(.gray)

            if showButton {
                Button(action: {
                    if speechManager.isRecording {
                        speechManager.stopRecording()
                    } else {
                        viewModel.resetStatuses()
//                        speechManager.setCurrentWordSet(currentSet)
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
                Spacer().frame(height: 80)
            }

            if speechManager.overallScore < 0.8 && !showButton {
                Button(action: {
                    showButton = true
                    nextButton = false
                }) {
                    Text("Retry")
                        .font(.title2)
                        .foregroundStyle(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Image("sign")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 60)
                        )
                }
                .padding(.bottom, 42)
                .frame(maxWidth: .infinity, maxHeight: 80)
            }
        }
        .padding()
        .onReceive(speechManager.$recognizedText, perform: viewModel.updateStatuses)
        .onReceive(speechManager.$pronunciationScores, perform: viewModel.updateScores)
        .onReceive(speechManager.$isRecording) { isRecording in
            if !isRecording && speechManager.overallScore > 0 {
                showButton = false
            }
        }
        .onChange(of: speechManager.wordSet1OverallScore) { newScore in
            if step == 1 {
                handleScoreChange(newScore)
                score = newScore
            }
        }
        .onChange(of: speechManager.wordSet2OverallScore) { newScore in
            if step == 3 {
                handleScoreChange(newScore)
                score = newScore
            }
        }

        .onChange(of: nextButton) { newValue in
            print("🎯 nextButton binding changed to: \(newValue) at step: \(step)")
        }
        .onAppear {
            print("🎯 WordNodes appeared - Step: \(step), hasPermission: \(speechManager.hasPermission)")
            
            viewModel.setWordSet(currentSet.nihongo.map { $0.trimmingCharacters(in: .punctuationCharacters) })
            
            if step == 1 {
                speechManager.setCurrentWordSet(currentSet, wordSetId: 1)
            } else if step == 3 {
                speechManager.setCurrentWordSet(currentSet, wordSetId: 2)
                nextButton = false
                showButton = true
            }
        }
    }
}

//#Preview {
//    WordNodes(nextButton: .constant(true), step: .constant(0))
//}

//struct WordNodes: View {
//    @StateObject private var speechManager = speechRecognitionManager()
//    @StateObject private var viewModel = QuizViewModel()
//    @State private var showButton = true
//    @Binding var nextButton: Bool
//    @Binding var step: Int
//
//    var currentSet: WordSet {
//        switch step {
//        case 1: return wordSets[0]
//        case 3: return wordSets[1]
//        default: return wordSets[0]
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Ask this to the staff:")
//                .font(.callout)
//
//            // Split words into two rows
//            let midIndex = currentSet.romaji.count * 2 / 4
//            let firstRow = zip(
//                currentSet.romaji.prefix(midIndex),
//                currentSet.nihongo.prefix(midIndex)
//            )
//            let secondRow = zip(
//                currentSet.romaji.suffix(from: midIndex),
//                currentSet.nihongo.suffix(from: midIndex)
//            )
//
//            HStack(spacing: 24) {
//                ForEach(Array(firstRow), id: \.1) { romaji, nihongo in
//                    let cleanNihongo = nihongo.trimmingCharacters(in: .punctuationCharacters)
//                    wordCard(
//                        romaji: romaji,
//                        nihongo: nihongo,
//                        status: viewModel.wordStatuses[cleanNihongo] ?? .neutral
//                    )
//                }
//            }
//
//            HStack(spacing: 24) {
//                ForEach(Array(secondRow), id: \.1) { romaji, nihongo in
//                    let cleanNihongo = nihongo.trimmingCharacters(in: .punctuationCharacters)
//                    wordCard(
//                        romaji: romaji,
//                        nihongo: nihongo,
//                        status: viewModel.wordStatuses[cleanNihongo] ?? .neutral
//                    )
//                }
//            }
//
//            Text(currentSet.english)
//                .font(.footnote)
//                .foregroundStyle(.gray)
//
//            if showButton {
//                Button(action: {
//                    print("🎙️ Button tapped")
//                    if speechManager.isRecording {
//                        print("🛑 Stopping recording")
//                        speechManager.stopRecording()
//                        // Don't hide button immediately - wait for score evaluation
//                    } else {
//                        print("▶️ Starting recording")
//                        viewModel.resetStatuses()
//                        speechManager.setCurrentWordSet(currentSet)
//                        speechManager.startRecording()
//                    }
//                }) {
//                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                        .font(.system(size: 56))
//                        .foregroundColor(speechManager.isRecording ? .red : Color("04B3AC"))
//                }
//                .frame(maxWidth: .infinity, maxHeight: 80)
//                .disabled(!speechManager.hasPermission)
//            } else {
//                VStack {
//                    
//                }
//                .frame(maxWidth: .infinity, maxHeight: 80)
//            }
//
//            if speechManager.overallScore < 0.8 && !showButton {
//                Button(action: {
//                    showButton = true
//                    nextButton = false // Reset next button when retrying
//                }) {
//                    Text("Retry")
//                        .font(.title2)
//                        .foregroundStyle(.black)
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .bottom)
//                        .background(
//                            Image("sign")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(maxHeight: 60)
//                        )
//                }
//                .frame(maxWidth: .infinity, maxHeight: 80)
//            }
//        }
//        .padding()
//        .onReceive(speechManager.$recognizedText) { text in
//            viewModel.updateStatuses(from: text)
//        }
//        .onReceive(speechManager.$pronunciationScores) { scores in
//            viewModel.updateScores(from: scores)
//        }
//        .onReceive(speechManager.$isRecording) { isRecording in
//            print("🎙️ Recording state changed: \(isRecording)")
//            // Hide button when recording stops and we have a score
//            if !isRecording && speechManager.overallScore > 0 {
//                showButton = false
//            }
//        }
//        .onChange(of: speechManager.overallScore) { newScore in
//            print("📊 Overall score changed to: \(newScore), Step: \(step), Current nextButton: \(nextButton)")
//            if newScore >= 0.8 {
//                print("✅ Score is good! Setting nextButton = true")
//                showButton = false
//                nextButton = true
//                print("🔄 After setting: nextButton = \(nextButton)")
//            } else if newScore > 0 && newScore < 0.8 {
//                print("❌ Score too low: \(newScore)")
//                // Score is available but not good enough
//                showButton = false // This will show the retry button
//                nextButton = false
//            }
//        }
//        .onChange(of: nextButton) { newValue in
//            print("🎯 nextButton binding changed to: \(newValue) at step: \(step)")
//        }
//        .onAppear {
//            print("🎯 WordNodes appeared - Step: \(step), hasPermission: \(speechManager.hasPermission)")
//            // Reset nextButton when starting a new recording session
//            if step == 3 {
//                nextButton = false
//                showButton = true
//            }
//        }
//    }
//}

//#Preview {
//    WordNodes(nextButton: .constant(false), step: .constant(1))
//}

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
        .scaleEffect(status == .excellent ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: status)
    }
}
