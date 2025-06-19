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
    
    // NEW: Separate overall scores for each word set
    @Published var wordSet1OverallScore: Double = 0.0
    @Published var wordSet2OverallScore: Double = 0.0
    @Published var overallScore: Double = 0.0 // Keep this for backward compatibility
    
    // NEW: Store scores for each word set separately
    @Published var wordSet1Scores: [String: Double] = [:]
    @Published var wordSet2Scores: [String: Double] = [:]

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioFileURL: URL?
    private var audioFileOutput: AVAudioFile?
    private var wordSegments: [SFTranscriptionSegment]?
    private var pendingAnalysisCount = 0
    private var forcedWordSetId: Int? = nil
    private var currentWordSetId: Int?
    
    var currentWordSet: WordSet?
    
    // NEW: Define word sets for easy identification
    private let wordSet1Words = ["すみません", "肉", "は", "入って", "います", "か"]
    private let wordSet2Words = ["ありがとう", "この", "チャーハン", "は", "エビ", "とか", "カニ", "入って", "います", "か"]
    
    private let wordSetPhrases = [
        "すみません肉は入っていますか",
        "すみませんこのチャーハンはエビとかカニ入っていますか"
    ]

    override init() {
        super.init()
        requestPermissions()
    }
    
    func setCurrentWordSet(_ wordSet: WordSet, wordSetId: Int) {
        self.currentWordSet = wordSet
        self.currentWordSetId = wordSetId
        print("🎯 Setting current word set to: \(getCleanWords(from: wordSet)), ID: \(wordSetId)")
        
        pronunciationScores.removeAll()
        overallScore = 0.0
        pendingAnalysisCount = 0
    }

    
    // NEW: Method to get current word set ID
    private func getCurrentWordSetId() -> Int? {
        guard let wordSet = currentWordSet else { return nil }
        let cleanWords = getCleanWords(from: wordSet)
        
        if cleanWords == wordSet1Words {
            return 1
        } else if cleanWords == wordSet2Words {
            return 2
        }
        return nil
    }
    
    // NEW: Method to clear scores for specific word set
    func clearScoresForWordSet(_ wordSetId: Int) {
        switch wordSetId {
        case 1:
            wordSet1Scores.removeAll()
            wordSet1OverallScore = 0.0
        case 2:
            wordSet2Scores.removeAll()
            wordSet2OverallScore = 0.0
        default:
            break
        }
    }
    
    // NEW: Method to get scores for specific word set
    func getScoresForWordSet(_ wordSetId: Int) -> [String: Double] {
        switch wordSetId {
        case 1:
            return wordSet1Scores
        case 2:
            return wordSet2Scores
        default:
            return [:]
        }
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
        
        print("🎤 Starting recording with word set: \(currentWordSet != nil ? "set" : "nil")")

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
        
        audioFileOutput = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This delay ensures the file is fully written before we try to process it
        }
    }

    private var isProcessingSegments = false
    
    func sliceWordsFromRecording() {
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
    
    func applySemanticMerging(to segments: [(start: Double, end: Double, word: String)]) -> [(start: Double, end: Double, word: String)] {
        var finalSegments: [(start: Double, end: Double, word: String)] = []
        var i = 0
        
        while i < segments.count {
            let current = segments[i]
            let next = i + 1 < segments.count ? segments[i + 1] : nil

            // Merge 'ござい' + 'ます' → 'ございます'
            if current.word == "ござい", let next = next, next.word == "ます" {
                finalSegments.append((start: current.start, end: next.end, word: "ございます"))
                i += 2
            }

            // Merge 'でき' + 'ますか' → 'できます' + 'か'
            else if current.word == "でき", let next = next, next.word == "ますか" {
                finalSegments.append((start: current.start, end: next.end, word: "できます"))
                finalSegments.append((start: next.start, end: next.end, word: "か"))
                i += 2
            }

            // Otherwise, keep as is
            else {
                finalSegments.append(current)
                i += 1
            }
        }
        
        return finalSegments
    }
    
    private func processSegmentsWithDuration(
        segments: [SFTranscriptionSegment],
        asset: AVAsset,
        audioDuration: Double,
        wordSet: WordSet
    ) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // STEP 1: Merge by timing
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

        // STEP 2: Apply semantic fixes
        let finalSegments = applySemanticMerging(to: mergedSegments)

        print("🔍 Final Segments:")
        for segment in finalSegments {
            print("   - '\(segment.word)' from \(segment.start)s to \(segment.end)s")
        }

        // STEP 3: Timing validation
        let totalRecognizedDuration = finalSegments.reduce(0.0) { $0 + ($1.end - $1.start) }
        let timingRatio = totalRecognizedDuration / audioDuration

        print("🔍 Timing validation: recognized=\(totalRecognizedDuration)s, audio=\(audioDuration)s, ratio=\(timingRatio)")

        if timingRatio < 0.1 {
            print("⚠️ Speech recognition timing seems incorrect. Using fallback strategy.")
            useFallbackTiming(mergedSegments: finalSegments, asset: asset, docs: docs, audioDuration: audioDuration, wordSet: wordSet)
        } else {
            let combinedPhrase = getCombinedPhrase(for: wordSet)
            if finalSegments.count == 1 && finalSegments[0].word == combinedPhrase {
                print("🎯 Detected full combined phrase for current word set, splitting into individual words")
                splitCombinedPhraseByNaturalPattern(finalSegments[0], asset: asset, docs: docs, audioDuration: audioDuration, wordSet: wordSet)
            } else {
                processSegments(finalSegments, asset: asset, docs: docs, audioDuration: audioDuration)
            }
        }

        isProcessingSegments = false
    }
    
    private func getCombinedPhrase(for wordSet: WordSet) -> String {
        return wordSet.nihongo.joined(separator: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "？", with: "")
            .replacingOccurrences(of: "?", with: "")
    }

    private func useFallbackTiming(mergedSegments: [(start: Double, end: Double, word: String)], asset: AVAsset, docs: URL, audioDuration: Double, wordSet: WordSet) {
        let combinedPhrase = getCombinedPhrase(for: wordSet)
        
        if mergedSegments.count == 1 && mergedSegments[0].word == combinedPhrase {
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
        let wordsWithPercentage = getNaturalPercentages(for: wordSet)
        
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
    
    private func getNaturalPercentages(for wordSet: WordSet) -> [(word: String, percentage: Double)] {
        let cleanWords = getCleanWords(from: wordSet)
        
        if cleanWords == wordSet1Words {
            return [
                ("すみません", 0.35),
                ("肉", 0.12),
                ("は", 0.06),
                ("入って", 0.24),
                ("います", 0.18),
                ("か", 0.06)
            ]
        } else if cleanWords == wordSet2Words {
            return [
                ("ありがとう", 0.21),
                ("この", 0.07),
                ("チャーハン", 0.18),
                ("は", 0.04),
                ("エビ", 0.07),
                ("とか", 0.07),
                ("カニ", 0.07),
                ("入って", 0.14),
                ("います", 0.11),
                ("か", 0.04)
            ]
        } else {
            let equalPercentage = 1.0 / Double(cleanWords.count)
            return cleanWords.map { word in
                (word: word, percentage: equalPercentage)
            }
        }
    }

    private func processSegments(_ segments: [(start: Double, end: Double, word: String)], asset: AVAsset, docs: URL, audioDuration: Double) {
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

        let cleanWord = wordGroup.word.replacingOccurrences(of: "/", with: "_")
        let outputURL = docs.appendingPathComponent("word_\(index)_\(cleanWord).m4a")
        
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
            let model = try KataKita07(configuration: MLModelConfiguration()).model
            let request = try SNClassifySoundRequest(mlModel: model)
            
            let analyzer = try SNAudioFileAnalyzer(url: url)
            analyzer.accessibilityHint = word
            
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
    
    // MODIFIED: Calculate overall score and update appropriate word set
    private func calculateOverallScore() {
        print("🔍 Starting calculateOverallScore")
        print("🔍 Current word set: \(currentWordSet != nil ? "exists" : "nil")")
        
        // First, try to determine word set from the scores themselves
        var wordSetId: Int?
        
        if let forcedId = currentWordSetId {
            wordSetId = forcedId
            print("✅ Using explicitly set wordSetId: \(forcedId)")
        }

        // Fallback: Try to determine from the scores
        if wordSetId == nil {
            wordSetId = determineWordSetFromScores()
            print("🔍 Word set ID from scores: \(wordSetId ?? -1)")
        }
        
        guard let finalWordSetId = wordSetId else {
            print("⚠️ Could not determine word set for scoring")
            overallScore = 0.0
            return
        }
        
        let targetWords = getTargetWordsForWordSet(finalWordSetId)
        var totalScore = 0.0
        var scoreCount = 0
        
        print("🔍 Target words for word set \(finalWordSetId): \(targetWords)")
        
        for word in targetWords {
            if let score = pronunciationScores[word] {
                totalScore += score
                scoreCount += 1
                print("📈 Using score for \(word): \(Int(score * 100))%")
            }
        }
        
        var calculatedScore: Double = 0.0
        
        if scoreCount > 0 {
            calculatedScore = totalScore / Double(scoreCount)
        } else if !pronunciationScores.isEmpty {
            let allScores = Array(pronunciationScores.values)
            calculatedScore = allScores.reduce(0, +) / Double(allScores.count)
            print("📊 Using fallback scoring from available scores")
        }
        
        // Update the appropriate word set scores
        switch finalWordSetId {
        case 1:
            wordSet1Scores = pronunciationScores
            wordSet1OverallScore = calculatedScore
            print("📊 Word Set 1 Final Score: \(Int(wordSet1OverallScore * 100))%")
        case 2:
            wordSet2Scores = pronunciationScores
            wordSet2OverallScore = calculatedScore
            print("📊 Word Set 2 Final Score: \(Int(wordSet2OverallScore * 100))%")
        default:
            print("⚠️ Unknown word set ID: \(finalWordSetId)")
        }
        
        // Keep backward compatibility
        overallScore = calculatedScore
        
        DispatchQueue.main.async {
            print("📊 Final Overall Score: \(Int(self.overallScore * 100))%")
        }
    }
    
    // NEW: Determine word set from the scores we have
    private func determineWordSetFromScores() -> Int? {
        let scoreKeys = Set(pronunciationScores.keys)
        let wordSet1Keys = Set(wordSet1Words)
        let wordSet2Keys = Set(wordSet2Words)
        
        let overlap1 = scoreKeys.intersection(wordSet1Keys).count
        let overlap2 = scoreKeys.intersection(wordSet2Keys).count
        
        print("🔍 Score overlap - WordSet1: \(overlap1), WordSet2: \(overlap2)")
        
        if overlap1 > overlap2 {
            return 1
        } else if overlap2 > overlap1 {
            return 2
        } else if overlap1 > 0 {
            // If equal overlap, prefer word set 1
            return 1
        }
        
        return nil
    }
    
    // NEW: Get target words for specific word set
    func getTargetWordsForWordSet(_ id: Int) -> [String] {
        switch id {
        case 1: return wordSets[0].nihongo.map { $0.trimmingCharacters(in: .punctuationCharacters) }
        case 2: return wordSets[1].nihongo.map { $0.trimmingCharacters(in: .punctuationCharacters) }
        default: return []
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
        
        var targetWord: String?
        let lowerIdentifier = identifier.lowercased()
        
        // First sentence mappings
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
        // Second sentence mappings
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
        } else if lowerIdentifier.contains("kono") || lowerIdentifier.contains("この") {
            targetWord = "この"
        } else if lowerIdentifier.contains("chaahan") || lowerIdentifier.contains("チャーハン") {
            targetWord = "チャーハン"
        } else if lowerIdentifier.contains("toka") || lowerIdentifier.contains("とか") {
            targetWord = "とか"
        } else if lowerIdentifier.contains("kani") || lowerIdentifier.contains("カニ") {
            targetWord = "カニ"
        }
        
        if let word = targetWord {
            DispatchQueue.main.async {
                let existingScore = self.pronunciationScores[word]
                
                if let existing = self.pronunciationScores[word] {
                    if confidence > existing {
                        print("📈 Updating score for \(word): \(Int(existing * 100))% → \(Int(confidence * 100))%")
                        self.pronunciationScores[word] = confidence
                    } else {
                        print("⚠️ Word '\(word)' already detected with score: \(Int(existing * 100))%, current: \(Int(confidence * 100))% - ignoring")
                    }
                } else {
                    self.pronunciationScores[word] = confidence
                    print("✅ First detection - Score for \(word): \(Int(confidence * 100))%")
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
