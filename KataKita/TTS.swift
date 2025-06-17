//
//  TTS.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 11/06/25.
//

import SwiftUI
import AVFoundation

struct TTS: View {
    @State private var text = "ありがとう"
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter Japanese text", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Speak") {
                speakJapanese(text)
            }
        }
        .padding()
    }
    
    func speakJapanese(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "jp-JP")
        utterance.rate = 0.5 // Adjust speed (0.0 - 1.0)
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

#Preview {
    TTS()
}
