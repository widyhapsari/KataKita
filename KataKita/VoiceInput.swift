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
    @Published var pronunciationScores: [String: Double] = [:] // New: Store ML scores
    @Published var overallScore: Double = 0.0 // New: Overall pronunciation score

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioFileURL: URL?
    private var audioFileOutput: AVAudioFile?
    private var wordSegments: [SFTranscriptionSegment]?
    private var pendingAnalysisCount = 0 // Track pending ML analyses
    
    // NEW: Add current word set tracking
    var currentWordSet: WordSet?
    
    // NEW: Combined phrases for each word set
    private let wordSetPhrases = [ // First word set
        "すみません肉は入っていますか" ,
        "すみませんこのチャーハンはエビとかカニ入っていますか"
    ]

    override init() {
        super.init()
        requestPermissions()
    }
    
    // NEW: Method to set current word set
    func setCurrentWordSet(_ wordSet: WordSet) {
        self.currentWordSet = wordSet
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

        // Reset scores for new recording
        pronunciationScores.removeAll()
        overallScore = 0.0
        pendingAnalysisCount = 0

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
                    }
                }

                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                    // Add delay to ensure audio file is completely written
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.sliceWordsFromRecording()
                    }
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
        
        // Ensure audio file is properly closed and flushed
        audioFileOutput = nil
        
        // Add a small delay to ensure file is completely written
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This delay ensures the file is fully written before we try to process it
        }
    }

    private var isProcessingSegments = false // Add flag to prevent multiple processing
    
    func sliceWordsFromRecording() {
        // Prevent multiple simultaneous processing
        guard !isProcessingSegments else {
            print("⚠️ Already processing segments, skipping duplicate call")
            return
        }
        
        guard let audioURL = self.audioFileURL,
              let segments = self.wordSegments,
              let wordSet = self.currentWordSet else {
            print("❌ Missing audio URL, segments, or current word set")
            return
        }
        
        // Check if audio file exists and has content
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: audioURL.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            print("🔍 Audio file size: \(fileSize) bytes")
            
            if fileSize == 0 {
                print("❌ Audio file is empty, cannot process")
                return
            }
        } catch {
            print("❌ Cannot access audio file: \(error)")
            return
        }
        
        isProcessingSegments = true

        let asset = AVAsset(url: audioURL)
        
        // Wait for the asset to load its duration
        Task {
            do {
                let duration = try await asset.load(.duration)
                let audioDuration = duration.seconds
                
                print("🔍 Audio file duration: \(audioDuration)s")
                print("🔍 Number of segments: \(segments.count)")
                
                await MainActor.run {
                    self.processSegmentsWithDuration(segments: segments, asset: asset, audioDuration: audioDuration, wordSet: wordSet)
                }
            } catch {
                print("❌ Failed to load asset duration: \(error)")
                await MainActor.run {
                    self.isProcessingSegments = false
                }
            }
        }
    }
    
    private func processSegmentsWithDuration(segments: [SFTranscriptionSegment], asset: AVAsset, audioDuration: Double, wordSet: WordSet) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        var mergedSegments: [(start: Double, end: Double, word: String)] = []
        var currentStart = segments[0].timestamp
        var currentEnd = segments[0].timestamp + segments[0].duration
        var currentWord = segments[0].substring

        for i in 1..<segments.count {
            let segment = segments[i]
            let gap = segment.timestamp - currentEnd

            if gap <= 0.2 {
                currentEnd = segment.timestamp + segment.duration
                currentWord += segment.substring
            } else {
                mergedSegments.append((start: currentStart, end: currentEnd, word: currentWord))
                currentStart = segment.timestamp
                currentEnd = segment.timestamp + segment.duration
                currentWord = segment.substring
            }
        }
        mergedSegments.append((start: currentStart, end: currentEnd, word: currentWord))

        print("🔍 Merged Segments:")
        for segment in mergedSegments {
            print("   - '\(segment.word)' from \(segment.start)s to \(segment.end)s")
        }

        // **NEW: Validate timing makes sense**
        let totalRecognizedDuration = mergedSegments.reduce(0.0) { $0 + ($1.end - $1.start) }
        let timingRatio = totalRecognizedDuration / audioDuration
        
        print("🔍 Timing validation: recognized=\(totalRecognizedDuration)s, audio=\(audioDuration)s, ratio=\(timingRatio)")
        
        if timingRatio < 0.1 { // If recognized timing is less than 10% of audio duration
            print("⚠️ Speech recognition timing seems incorrect. Using fallback strategy.")
            useFallbackTiming(mergedSegments: mergedSegments, asset: asset, docs: docs, audioDuration: audioDuration, wordSet: wordSet)
        } else {
            // NEW: Check if it's a combined phrase for the current word set
            let combinedPhrase = getCombinedPhrase(for: wordSet)
            if mergedSegments.count == 1 && mergedSegments[0].word == combinedPhrase {
                print("🎯 Detected full combined phrase for current word set, splitting into individual words")
                splitCombinedPhraseByNaturalPattern(mergedSegments[0], asset: asset, docs: docs, audioDuration: audioDuration, wordSet: wordSet)
            } else {
                // Handle normal segmented words
                processSegments(mergedSegments, asset: asset, docs: docs, audioDuration: audioDuration)
            }
        }
        
        // Reset the processing flag
        isProcessingSegments = false
    }
    
    // NEW: Get combined phrase for a word set
    private func getCombinedPhrase(for wordSet: WordSet) -> String {
        return wordSet.nihongo.joined(separator: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "？", with: "")
            .replacingOccurrences(of: "?", with: "")
    }

    private func useFallbackTiming(mergedSegments: [(start: Double, end: Double, word: String)], asset: AVAsset, docs: URL, audioDuration: Double, wordSet: WordSet) {
        // Use the full audio duration and split it evenly based on recognized words
        let combinedPhrase = getCombinedPhrase(for: wordSet)
        
        if mergedSegments.count == 1 && mergedSegments[0].word == combinedPhrase {
            // Split the full audio into equal parts based on word count
            let targetWords = getCleanWords(from: wordSet)
            let wordDuration = audioDuration / Double(targetWords.count)
            
            var correctedSegments: [(start: Double, end: Double, word: String)] = []
            
            for (index, word) in targetWords.enumerated() {
                let start = Double(index) * wordDuration
                let end = start + wordDuration
                correctedSegments.append((start: start, end: end, word: word))
            }
            
            pendingAnalysisCount = correctedSegments.count
            
            for (index, wordGroup) in correctedSegments.enumerated() {
                exportAndAnalyzeSegment(wordGroup, index: index, asset: asset, docs: docs, audioDuration: audioDuration)
            }
        } else {
            // For multiple segments, distribute the audio duration evenly
            let segmentDuration = audioDuration / Double(mergedSegments.count)
            var correctedSegments: [(start: Double, end: Double, word: String)] = []
            
            for (index, segment) in mergedSegments.enumerated() {
                let start = Double(index) * segmentDuration
                let end = start + segmentDuration
                correctedSegments.append((start: start, end: end, word: segment.word))
            }
            
            pendingAnalysisCount = correctedSegments.count
            
            for (index, wordGroup) in correctedSegments.enumerated() {
                exportAndAnalyzeSegment(wordGroup, index: index, asset: asset, docs: docs, audioDuration: audioDuration)
            }
        }
    }
    
    // NEW: Get clean words from word set (removing punctuation)
    private func getCleanWords(from wordSet: WordSet) -> [String] {
        return wordSet.nihongo.map { word in
            word.trimmingCharacters(in: CharacterSet(charactersIn: ".？?"))
        }
    }
    
    private func splitCombinedPhraseByNaturalPattern(_ segment: (start: Double, end: Double, word: String), asset: AVAsset, docs: URL, audioDuration: Double, wordSet: WordSet) {
        var actualStart: Double
        var actualEnd: Double
        
        let recognizedDuration = segment.end - segment.start
        let timingRatio = recognizedDuration / audioDuration
        
        if timingRatio < 0.1 {
            actualStart = 0.0
            actualEnd = audioDuration
        } else {
            actualStart = segment.start
            actualEnd = segment.end
        }
        
        let totalDuration = actualEnd - actualStart
        
        // NEW: Get natural speech percentages based on the current word set
        let wordsWithPercentage = getNaturalPercentages(for: wordSet)
        
        // Verify percentages add up to 1.0
        let totalPercentage = wordsWithPercentage.reduce(0) { $0 + $1.percentage }
        print("🔍 Total percentage: \(totalPercentage)")
        
        var segments: [(start: Double, end: Double, word: String)] = []
        var currentTime = actualStart
        
        for wordInfo in wordsWithPercentage {
            let wordDuration = wordInfo.percentage * totalDuration
            let wordEnd = currentTime + wordDuration
            
            segments.append((start: currentTime, end: wordEnd, word: wordInfo.word))
            print("🔍 '\(wordInfo.word)' (\(Int(wordInfo.percentage * 100))%): \(currentTime)s to \(wordEnd)s (\(wordDuration)s)")
            
            currentTime = wordEnd
        }
        
        pendingAnalysisCount = segments.count
        
        for (index, wordGroup) in segments.enumerated() {
            exportAndAnalyzeSegment(wordGroup, index: index, asset: asset, docs: docs, audioDuration: audioDuration)
        }
    }
    
    // NEW: Get natural percentages for different word sets
    private func getNaturalPercentages(for wordSet: WordSet) -> [(word: String, percentage: Double)] {
        let cleanWords = getCleanWords(from: wordSet)
        
        // Define percentages for each word set
        if cleanWords == ["すみません", "肉", "は", "入って", "います", "か"] {
            // First word set percentages (Total: 3.4 seconds)
            return [
                ("すみません", 0.35),    // 35% - 1.2s/3.4s - polite opening, emphasized
                ("肉", 0.12),           // 12% - 0.4s/3.4s - important noun
                ("は", 0.06),           // 6% - 0.2s/3.4s - particle
                ("入って", 0.24),        // 24% - 0.8s/3.4s - verb, clear pronunciation
                ("います", 0.18),        // 18% - 0.6s/3.4s - polite auxiliary
                ("か", 0.06)            // 6% - 0.2s/3.4s - question particle
            ]
        } else if cleanWords == ["ありがとう", "この", "チャーハン", "は", "エビ", "とか", "カニ", "入って", "います", "か"] {
            // Second word set percentages (Total: 5.6 seconds)
            return [
                ("ありがとう", 0.21),    // 21% - 1.2s/5.6s - polite greeting
                ("この", 0.07),         // 7% - 0.4s/5.6s - demonstrative
                ("チャーハン", 0.18),    // 18% - 1.0s/5.6s - main noun
                ("は", 0.04),           // 4% - 0.2s/5.6s - particle
                ("エビ", 0.07),         // 7% - 0.4s/5.6s - allergen word
                ("とか", 0.07),         // 7% - 0.4s/5.6s - conjunction
                ("カニ", 0.07),         // 7% - 0.4s/5.6s - allergen word
                ("入って", 0.14),        // 14% - 0.8s/5.6s - verb form
                ("います", 0.11),        // 11% - 0.6s/5.6s - polite auxiliary
                ("か", 0.04)            // 4% - 0.2s/5.6s - question particle
            ]
        } else {
            // Fallback: equal distribution
            let equalPercentage = 1.0 / Double(cleanWords.count)
            return cleanWords.map { word in
                (word: word, percentage: equalPercentage)
            }
        }
    }

    
    private func processSegments(_ segments: [(start: Double, end: Double, word: String)], asset: AVAsset, docs: URL, audioDuration: Double) {
        // Set pending analysis count
        pendingAnalysisCount = segments.count
        
        for (index, wordGroup) in segments.enumerated() {
            exportAndAnalyzeSegment(wordGroup, index: index, asset: asset, docs: docs, audioDuration: audioDuration)
        }
    }
    
    private func exportAndAnalyzeSegment(_ wordGroup: (start: Double, end: Double, word: String), index: Int, asset: AVAsset, docs: URL, audioDuration: Double) {
        let start = wordGroup.start
        let duration = wordGroup.end - wordGroup.start
        
        print("🔍 Checking segment '\(wordGroup.word)': \(start)s to \(wordGroup.end)s against audio duration \(audioDuration)s")

        if wordGroup.end > audioDuration || start < 0 || duration <= 0 {
            print("⚠️ Skipping '\(wordGroup.word)': out of bounds. Start: \(start), End: \(wordGroup.end), Duration: \(duration), AudioDuration: \(audioDuration)")
            DispatchQueue.main.async {
                self.pendingAnalysisCount -= 1
                self.checkAnalysisCompletion()
            }
            return
        }

        let startCM = CMTime(seconds: start, preferredTimescale: 600)
        let durationCM = CMTime(seconds: duration, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startCM, duration: durationCM)

        // Clean up the filename to avoid issues
        let cleanWord = wordGroup.word.replacingOccurrences(of: "/", with: "_")
        let outputURL = docs.appendingPathComponent("word_\(index)_\(cleanWord).m4a")
        
        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("❌ Could not create export session.")
            DispatchQueue.main.async {
                self.pendingAnalysisCount -= 1
                self.checkAnalysisCompletion()
            }
            return
        }

        exportSession.timeRange = timeRange
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a

        print("🎬 Starting export for '\(wordGroup.word)' to \(outputURL.lastPathComponent)")
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    print("✅ Exported \(wordGroup.word) to \(outputURL.lastPathComponent)")
                    self.analyzeAudio(at: outputURL, for: wordGroup.word)
                } else {
                    let errorMsg = exportSession.error?.localizedDescription ?? "unknown error"
                    print("❌ Failed to export \(wordGroup.word): \(errorMsg)")
                    print("   Export status: \(exportSession.status.rawValue)")
                    self.pendingAnalysisCount -= 1
                    self.checkAnalysisCompletion()
                }
            }
        }
    }

    func analyzeAudio(at url: URL, for word: String) {
        print("🎯 Starting analysis for: '\(word)'")
        do {
            let model = try KataKita_V0(configuration: MLModelConfiguration()).model
            let request = try SNClassifySoundRequest(mlModel: model)
            
            let analyzer = try SNAudioFileAnalyzer(url: url)
            
            // Store word context for later use
            analyzer.accessibilityHint = word // Using this to pass word info
            
            try analyzer.add(request, withObserver: self)
            analyzer.analyze()
        } catch {
            print("❌ ML analysis error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.pendingAnalysisCount -= 1
                self.checkAnalysisCompletion()
            }
        }
    }
    
    private func checkAnalysisCompletion() {
        print("📊 Pending analyses: \(pendingAnalysisCount)")
        print("📊 Current scores: \(pronunciationScores)")
        
        if pendingAnalysisCount <= 0 {
            calculateOverallScore()
        }
    }
    
    private func calculateOverallScore() {
        guard let wordSet = currentWordSet else {
            print("⚠️ No current word set available for scoring")
            overallScore = 0.0
            return
        }
        
        let targetWords = getCleanWords(from: wordSet)
        var totalScore = 0.0
        var scoreCount = 0
        
        for word in targetWords {
            if let score = pronunciationScores[word] {
                totalScore += score
                scoreCount += 1
                print("📈 Using score for \(word): \(Int(score * 100))%")
            }
        }
        
        if scoreCount > 0 {
            overallScore = totalScore / Double(scoreCount)
        } else {
            // Fallback: if no individual word scores, try any available scores
            if !pronunciationScores.isEmpty {
                let allScores = Array(pronunciationScores.values)
                overallScore = allScores.reduce(0, +) / Double(allScores.count)
                print("📊 Using fallback scoring from available scores")
            } else {
                overallScore = 0.0
                print("⚠️ No scores available for calculation")
            }
        }
        
        DispatchQueue.main.async {
            print("📊 Final Overall Score: \(Int(self.overallScore * 100))%")
        }
    }
}

extension speechRecognitionManager: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }

        let confidence = Double(classification.confidence)
        let identifier = classification.identifier
        
        print("🎧 ML Result: \(identifier) - Confidence: \(Int(confidence * 100))%")
        
        // NEW: Map ML model output to Japanese words (expanded for both word sets)
        var targetWord: String?
        
        // Convert to lowercase for case-insensitive comparison
        let lowerIdentifier = identifier.lowercased()
        
        // First sentence
        if lowerIdentifier.contains("sumimasen") || lowerIdentifier.contains("すみません") {
            targetWord = "すみません"
        } else if lowerIdentifier.contains("niku") || lowerIdentifier.contains("肉") {
            targetWord = "肉"
        } else if lowerIdentifier.contains("wa") || lowerIdentifier.contains("は") {
            targetWord = "は"
        } else if lowerIdentifier.contains("haitte") || lowerIdentifier.contains("入って") {
            targetWord = "入って"
        } else if lowerIdentifier.contains("imasu") || lowerIdentifier.contains("います") {
            targetWord = "います"
        }
        
        // second sentence
        else if lowerIdentifier.contains("arigatou") || lowerIdentifier.contains("ありがとう") {
            targetWord = "ありがとう"
        } else if lowerIdentifier.contains("gozaimasu") || lowerIdentifier.contains("ございます") {
            targetWord = "ございます"
        } else if lowerIdentifier.contains("ebi") || lowerIdentifier.contains("エビ") {
            targetWord = "エビ"
        } else if lowerIdentifier.contains("nuki") || lowerIdentifier.contains("抜き") {
            targetWord = "抜き"
        } else if lowerIdentifier.contains("tte") || lowerIdentifier.contains("って") {
            targetWord = "って"
        } else if lowerIdentifier.contains("dekimasu") || lowerIdentifier.contains("できます") {
            targetWord = "できます"
        } else if lowerIdentifier.contains("ka") || lowerIdentifier.contains("か") {
            targetWord = "か"
        }
        // NEW: Second word set mappings
        
        if let word = targetWord {
            DispatchQueue.main.async {
                // More explicit check: only update if word doesn't exist OR has a lower confidence
                let existingScore = self.pronunciationScores[word]
                
                if existingScore == nil {
                    // First detection for this word
                    self.pronunciationScores[word] = confidence
                    print("✅ First detection - Score for \(word): \(Int(confidence * 100))%")
                } else if confidence > existingScore! {
                    // Only update if new confidence is higher (optional enhancement)
                    print("📈 Higher confidence found for \(word): \(Int(confidence * 100))% vs \(Int(existingScore! * 100))%")
                    // Uncomment the line below if you want to allow updates with higher confidence
                    // self.pronunciationScores[word] = confidence
                } else {
                    print("⚠️ Word '\(word)' already detected with score: \(Int(existingScore! * 100))%, current: \(Int(confidence * 100))% - ignoring")
                }
            }
        } else {
            print("⚠️ No target word mapping found for identifier: \(identifier)")
        }
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ Sound analysis failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.pendingAnalysisCount -= 1
            self.checkAnalysisCompletion()
        }
    }

    func requestDidComplete(_ request: SNRequest) {
        print("✅ Analysis completed")
        DispatchQueue.main.async {
            self.pendingAnalysisCount -= 1
            self.checkAnalysisCompletion()
        }
    }
}
