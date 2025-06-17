//
//  AudioPlayer.swift
//  KataKita
//
//  Created by Arief Roihan Nur Rahman on 17/06/25.
//

import AVFoundation

class AudioService {
    func player(named fileName: String) throws -> AVAudioPlayer {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            throw NSError(
                domain: "AudioPlayerService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Audio file not found"]
            )
        }

        return try AVAudioPlayer(contentsOf: url)
    }
}
