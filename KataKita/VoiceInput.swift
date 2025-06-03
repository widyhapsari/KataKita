//
//  VoiceInput.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 03/06/25.
//

import Speech
import AVFoundation

class speechRecognitionManager: ObservableObject {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var hasPermission = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init () {
        requestPermissions()
    }
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            let speechAllowed = authStatus == .authorized
            
            AVAudioSession.sharedInstance().requestRecordPermission { micAllowed in
                DispatchQueue.main.async {
                    self.hasPermission = speechAllowed && micAllowed
                    print("Speech permission: \(speechAllowed), Mic permission: \(micAllowed)")
                }
            }
        }
    }
    
    // recording and recognizing
    func startRecording() {
        guard hasPermission else { return }
        
        if isRecording {
            stopRecording()
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {result, error in
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    print("Recognized: \(text)")
                    
                    DispatchQueue.main.async {
//                        self.recognizedTextLabel.text = text
                        self.recognizedText = text
                    }
                }
                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                }
            }
            
            isRecording = true
        } catch {
            print("error starting recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
    }
}
