//
//  AudioSpeaker.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 17/06/25.
//

import SwiftUI
import AVFoundation

enum AudioPlayerViewModelState {
    case loading
    case loaded
    case error(Error)
}

class WelcomeViewModel: ObservableObject {
    @Published private(set) var state: AudioPlayerViewModelState = .loading
    
    private var audioService: AudioService
    private var audioPlayer: AVAudioPlayer? = nil
    
    init() {
        self.audioService = AudioService()
        updateState(.loaded)
    }
    
    func playAudio(named fileName: String) {
        do {
            self.audioPlayer = try audioService.player(named: fileName)
            audioPlayer?.play()
        } catch {
            print(error.localizedDescription)
            updateState(.error(error))
        }
    }
    func stopAudio() {
        if audioPlayer == nil { return }
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension WelcomeViewModel {
    func updateState(_ state: AudioPlayerViewModelState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}
