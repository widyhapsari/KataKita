//
//  ViewModel.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 17/06/25.
//

import Foundation
import SwiftUI

enum WordStatus {
    case neutral
    case excellent
    case good
    case bad
}

class QuizViewModel: ObservableObject {
    @Published var wordStatuses: [String: WordStatus] = [:]
    @Published var wordScores: [String: Double] = [:]
    
    @Published var currentWords: [String] = []
    
    static let wordSet1 = ["すみません", "この", "チャーハン", "は", "エビ", "とか", "カニ", "入って", "います", "か"]
    static let wordSet2 = ["ありがとう", "ございます", "エビ", "抜き", "って", "できます", "か"]
    
    func setWordSet(_ words: [String]) {
        DispatchQueue.main.async {
            self.currentWords = words
            self.wordStatuses = Dictionary(uniqueKeysWithValues: words.map { ($0, .neutral) })
            self.wordScores = Dictionary(uniqueKeysWithValues: words.map { ($0, 0.0) })
        }
    }
    
    private var detectedWords: Set<String> = []
    
    func updateStatuses(from recognizedText: String) {
        print("🔍 Recognized text: '\(recognizedText)'")
        
        guard !recognizedText.isEmpty else {
            print("⚠️ Empty recognized text, skipping text-based status update")
            return
        }
        
        var updated = wordStatuses
        for word in currentWords {
            if recognizedText.contains(word) {
                updated[word] = .excellent
                print("✅ Found: \(word)")
            } else {
                print("❌ Missing: \(word)")
            }
        }
        
        DispatchQueue.main.async {
            self.wordStatuses = updated
        }
    }

    
    func updateScores(from mlScores: [String: Double]) {
        DispatchQueue.main.async {
            for (word, score) in mlScores {
                self.wordScores[word] = score
                
                // Update status based on ML confidence
                if score >= 0.9 {
                    self.wordStatuses[word] = .excellent
                } else if score >= 0.7 {
                    self.wordStatuses[word] = .good
                } else {
                    self.wordStatuses[word] = .bad
                }
            }
        }
    }
    
    // Reset function for new attempts
    func resetStatuses() {
        DispatchQueue.main.async {
            self.wordStatuses = Dictionary(uniqueKeysWithValues: self.currentWords.map { ($0, .neutral) })
            self.wordScores = Dictionary(uniqueKeysWithValues: self.currentWords.map { ($0, 0.0) })
        }
    }
}
