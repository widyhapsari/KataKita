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
    case correct
    case incorrect
}

class QuizViewModel: ObservableObject {
    @Published var wordStatuses: [String: WordStatus] = [
        "ありがとう": .neutral,
        "ございます": .neutral
    ]
    
    func updateStatuses(from recognizedText: String) {
        print("🔍 Recognized text: '\(recognizedText)'")
        
        // Don't reset to incorrect immediately - let them stay neutral until we have results
        var updated = wordStatuses
        
        // Check each word in the recognized text
        let words = ["ありがとう", "ございます"]
        for word in words {
            // Check if the word appears in recognized text
            if recognizedText.contains(word) {
                updated[word] = .correct
                print("✅ Found: \(word)")
            } else if !recognizedText.isEmpty {
                // Only mark as incorrect if we have some recognition result
                updated[word] = .incorrect
                print("❌ Missing: \(word)")
            }
        }
        
        // Update the published property on main thread
        DispatchQueue.main.async {
            self.wordStatuses = updated
        }
    }
}
