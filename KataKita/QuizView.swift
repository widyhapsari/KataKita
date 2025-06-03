//
//  QuizView.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 03/06/25.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var speechManager = speechRecognitionManager()
    
    var body: some View {
        VStack {
            Button(action: {
                speechManager.startRecording()
            }) {
                HStack {
                    Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title)
                    
                }
            }
            .disabled(!speechManager.hasPermission)
        }
    }
}

#Preview {
    QuizView()
}
