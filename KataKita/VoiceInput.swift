//
//  VoiceInput.swift
//  KataKita
//
//  Created by Rastya Widya Hapsari on 03/06/25.
//

import Speech
import AVFAudio
import SoundAnalysis
import CoreML

class speechRecognitionManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var hasPermission = false
    @Published var pronunciationScores: [String: Double] = [:]
    @Published var overallScore: Double = 0.0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioFileURL: URL?
    private var audioFileOutput: AVAudioFile?
    private var wordSegments: [SFTranscriptionSegment]?

    override init() {
        super.init()
        requestPermissions()
    }

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            let speechAllowed = authStatus == .authorized

            AVAudioSession.sharedInstance().requestRecordPermission { micAllowed in
                DispatchQueue.main.async {
                    self.hasPermission = speechAllowed && micAllowed
                    print("🎤 Speech: \(speechAllowed), Mic: \(micAllowed)")
                }
            }
        }
    }

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
                try? self.audioFileOutput?.write(from: buffer)
            }

            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documents.appendingPathComponent("recordedAudio.m4a")
            self.audioFileURL = fileURL

            let settings = inputNode.outputFormat(forBus: 0).settings
            audioFileOutput = try AVAudioFile(forWriting: fileURL, settings: settings)

            audioEngine.prepare()
            try audioEngine.start()

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.recognizedText = result.bestTranscription.formattedString
                        self.wordSegments = result.bestTranscription.segments
                        print("🎤 Recognition result: '\(self.recognizedText)'")
                        print("🎤 Segments count: \(result.bestTranscription.segments.count)")
                    }
                }

                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                    self.sliceWordsFromRecording()
                }
            }

            isRecording = true
        } catch {
            print("❌ Error starting recording: \(error)")
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

    func sliceWordsFromRecording() {
        guard let audioURL = self.audioFileURL,
              let segments = self.wordSegments else { return }

        let asset = AVAsset(url: audioURL)
        let audioDuration = asset.duration.seconds
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        var mergedSegments: [(start: Double, end: Double, word: String)] = []
        var currentStart = segments[0].timestamp
        var currentEnd = segments[0].timestamp + segments[0].duration
        var currentWord = segments[0].substring

        for i in 1..<segments.count {
            let segment = segments[i]
            let gap = segment.timestamp - currentEnd

            if gap <= 0.2 {
                // Merge with previous
                currentEnd = segment.timestamp + segment.duration
                currentWord += segment.substring
            } else {
                // Save current word
                mergedSegments.append((start: currentStart, end: currentEnd, word: currentWord))
                currentStart = segment.timestamp
                currentEnd = segment.timestamp + segment.duration
                currentWord = segment.substring
            }
        }
        // Add the last merged segment
        mergedSegments.append((start: currentStart, end: currentEnd, word: currentWord))

        for (index, wordGroup) in mergedSegments.enumerated() {
            let start = wordGroup.start
            let duration = wordGroup.end - wordGroup.start

            if wordGroup.end > audioDuration {
                print("⚠️ Skipping '\(wordGroup.word)': out of bounds.")
                continue
            }

            let startCM = CMTime(seconds: start, preferredTimescale: 600)
            let durationCM = CMTime(seconds: duration, preferredTimescale: 600)
            let timeRange = CMTimeRange(start: startCM, duration: durationCM)

            let outputURL = docs.appendingPathComponent("word_\(index)_\(wordGroup.word).m4a")
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
                print("❌ Could not create export session.")
                continue
            }

            exportSession.timeRange = timeRange
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .m4a

            exportSession.exportAsynchronously {
                if exportSession.status == .completed {
                    print("✅ Exported \(wordGroup.word) to \(outputURL.lastPathComponent)")
                    self.analyzeAudio(at: outputURL)
                } else {
                    print("❌ Failed to export \(wordGroup.word): \(exportSession.error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }

    func analyzeAudio(at url: URL) {
        do {
            let model = try Words_1(configuration: MLModelConfiguration()).model
            let request = try SNClassifySoundRequest(mlModel: model)
            let analyzer = try SNAudioFileAnalyzer(url: url)
            try analyzer.add(request, withObserver: self)
            analyzer.analyze()
        } catch {
            print("❌ ML analysis error: \(error.localizedDescription)")
        }
    }
}

extension speechRecognitionManager: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let top = result.classifications.first else { return }

        print("🎧 Detected: \(top.identifier) (\(top.confidence))")
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ Sound analysis failed: \(error.localizedDescription)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("✅ Analysis completed")
    }
}
