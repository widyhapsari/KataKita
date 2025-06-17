import Foundation
import AVFoundation
import SoundAnalysis

class SoundClassifier: NSObject, ObservableObject, SNResultsObserving {
    private let audioEngine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer!
    private var inputFormat: AVAudioFormat!
    private let queue = DispatchQueue(label: "SoundAnalysisQueue")

    @Published var prediction: String = "Listening..."
    @Published var isRunning = false  // ← Add this

    override init() {
        super.init()
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)
    }

    func start() {
        guard !isRunning else { return }

        let request: SNClassifySoundRequest
        do {
            request = try SNClassifySoundRequest(mlModel: Words_1().model)
        } catch {
            print("❌ Failed to load model: \(error)")
            return
        }

        do {
            try analyzer.add(request, withObserver: self)

            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8192, format: inputFormat) { buffer, _ in
                self.queue.async {
                    self.analyzer.analyze(buffer, atAudioFramePosition: 0)
                }
            }

            try audioEngine.start()
            isRunning = true
        } catch {
            print("❌ Error starting audio engine: \(error)")
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRunning = false
    }

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else {
            return
        }

        DispatchQueue.main.async {
            self.prediction = "\(classification.identifier) (\(String(format: "%.2f", classification.confidence)))"
        }
    }
}
