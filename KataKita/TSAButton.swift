//
//  TSAButton.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 15/06/25.
//
import SwiftUI

struct TSAButton: View {
    @StateObject private var classifier = SoundClassifier()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detected:")
                .font(.headline)
            Text(classifier.prediction)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.blue)
            
            Button(action: {
                if classifier.isRunning {
                    classifier.stop()
                } else {
                    classifier.start()
                }
            }) {
                HStack {
                    Image(systemName: classifier.isRunning ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(classifier.isRunning ? .red : .green)
                }
            }
        }
        .padding()
    }
}
