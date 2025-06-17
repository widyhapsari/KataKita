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
    @Published var wordStatuses: [String: WordStatus] = [
        "ありがとう": .neutral,
        "ございます": .neutral,
        "エビ": .neutral,
        "抜き": .neutral,
        "って": .neutral,
        "言います": .neutral,
        "か": .neutral
    ]
    
    @Published var wordScores: [String: Double] = [
        "ありがとう": 0.0,
        "ございます": 0.0,
        "エビ": 0.0,
        "抜き": 0.0,
        "って": 0.0,
        "言います": 0.0,
        "か": 0.0
    ]
    
    func updateStatuses(from recognizedText: String) {
        print("🔍 Recognized text: '\(recognizedText)'")
        
        var updated = wordStatuses
        
        // Check each word in the recognized text
        let words = ["ありがとう",
                    "ございます",
                    "エビ",
                    "抜き",
                    "って",
                    "言います",
                    "か"]
        for word in words {
            // Check if the word appears in recognized text
            if recognizedText.contains(word) {
                updated[word] = .excellent
                print("✅ Found: \(word)")
            } else if !recognizedText.isEmpty {
                // Only mark as incorrect if we have some recognition result
                updated[word] = .bad
                print("❌ Missing: \(word)")
            }
        }
        
        // Update the published property on main thread
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
            self.wordStatuses = [
                "ありがとう": .neutral,
                "ございます": .neutral,
                "エビ": .neutral,
                "抜き": .neutral,
                "って": .neutral,
                "言います": .neutral,
                "か": .neutral
            ]
            self.wordScores = [
                "ありがとう": 0.0,
                "ございます": 0.0,
                "エビ": 0.0,
                "抜き": 0.0,
                "って": 0.0,
                "言います": 0.0,
                "か": 0.0
            ]
        }
    }
}
