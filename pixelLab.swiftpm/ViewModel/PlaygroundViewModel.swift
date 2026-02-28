import SwiftUI
import UIKit
import Combine

@MainActor
final class PlaygroundViewModel: ObservableObject {
    
    // MARK: - Inputs (from Challenge + Sample)
    let challenge: Challenge
    let originalAssetName: String
    
    // MARK: - Gate / Preprocess
    @Published var showPreprocessGate: Bool = true
    @Published var preprocess = PreprocessOptions(resizeOn: true, normalizeOn: true, grayscaleOn: true)
    
    // MARK: - Kernel / Metrics / Evaluation
    @Published var kernel: Kernel = .identity()
    @Published var metrics: KernelMetrics = KernelAnalysisService.analyze(.identity())
    @Published var evaluation: EvaluationResult = EvaluationResult()
    
    // MARK: - Images for UI
    @Published var originalUIImage: UIImage? = nil
    @Published var outputUIImage: UIImage? = nil
    
    // MARK: - Completion Prompt
    @Published var showCompletionPrompt: Bool = false
    @Published var completionPhrase: String = ""
    private static let encouragingPhrases: [String] = [
        "Excellent thinker!!", "Brilliant work!", "Fantastic job!",
        "You nailed it!", "Great problem solving!", "Outstanding!",
        "Superb reasoning!", "Well done!"
    ]
    
    // MARK: - Internal state
    private var processed: PreprocessService.Result? = nil
    private var targetBuffer: [Float]? = nil
    private var hasProducedOutput = false
    private var computeTask: Task<Void, Never>? = nil
    
    // MARK: - Haptics
    private let haptics = UINotificationFeedbackGenerator()
    private var hasCelebrated: Bool = false
    
    // MARK: - Combine
    private let kernelChangeSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Accessibility announcements
    private var lastAnnouncedPercent: Int? = nil
    private var lastAnnouncementAt: Date = .distantPast
    private let announceStep: Int = 5
    private let announceDebounce: TimeInterval = 1.0
    
    // MARK: - Init
    init(challenge: Challenge, originalAssetName: String) {
        self.challenge = challenge
        self.originalAssetName = originalAssetName
        self.originalUIImage = ImageLoader.loadUIImage(named: originalAssetName)
        self.evaluation.statusText = "Not Started"
        
        haptics.prepare()
        
        kernelChangeSubject
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] in
                guard let self else { return }
                self.computeTask?.cancel()
                self.haptics.prepare()
                self.computeTask = Task { [weak self] in
                    guard let self else { return }
                    self.computeOutputAndEvaluate()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Core Logic Updates

        private func computeOutputAndEvaluate() {
            guard !showPreprocessGate, let p = processed, let target = targetBuffer else { return }
            
            let out = ConvolutionService.convolve3x3(
                input: p.gray, width: p.width, height: p.height,
                kernel: kernel, normalized01: preprocess.normalizeOn
            )
            
            if !hasProducedOutput { hasProducedOutput = true }
            outputUIImage = out.image
            
            let userValues = kernel.values.flatMap { $0 }.map { Float($0) }
            let targetValues = challenge.idealKernel.values.flatMap { $0 }.map { Float($0) }

            let progressiveScore = SimilarityService.nccSimilarityPercent(
                a: out.buffer, b: target,
                userKernel: userValues, targetKernel: targetValues
            )
            
            // 1) Rules Check (Validates the "Math" of the filter)
            let rulesOK = rulesPass(challenge: challenge, metrics: metrics)
            
            // 2) Behavioral Completion Logic
            let behavioralThreshold: Double = 65.0
            let complete = rulesOK && (progressiveScore >= behavioralThreshold)
            
            // Capture previous completion state BEFORE updating
            let wasComplete = evaluation.isComplete
            
            // 3) Update UI state
            evaluation.similarityPercent = progressiveScore
            evaluation.isComplete = complete
            
            // Trigger Success Celebration
            if !wasComplete && complete && !hasCelebrated {
                hasCelebrated = true
                haptics.notificationOccurred(.success)
                haptics.prepare()
                completionPhrase = Self.encouragingPhrases.randomElement() ?? "Great job!"
                showCompletionPrompt = true
                UIAccessibility.post(notification: .screenChanged, argument: "Challenge completed.")
            }
            
            // Guidance Logic: Help user if they have behavioral similarity but wrong rules
            if progressiveScore >= behavioralThreshold && !rulesOK {
                evaluation.statusText = "Image looks close! Check Kernel Rules."
            } else {
                evaluation.statusText = complete ? "Completed" : "In Progress"
            }

            announceSimilarityIfNeeded(displayed: progressiveScore, complete: complete)
        }

    private func announceSimilarityIfNeeded(displayed: Double, complete: Bool) {
        let now = Date()
        guard now.timeIntervalSince(lastAnnouncementAt) >= announceDebounce else { return }
        
        let stepRounded = max(0, min(100, Int((displayed / Double(announceStep)).rounded() * Double(announceStep))))
        
        if lastAnnouncedPercent != stepRounded || (complete && !hasCelebrated) {
            lastAnnouncedPercent = stepRounded
            lastAnnouncementAt = now
            
            let msg = complete
                ? "Challenge Complete! Similarity \(stepRounded) percent. Goal reached."
                : "Similarity \(stepRounded) percent."
                
            UIAccessibility.post(notification: .announcement, argument: msg)
        }
    }
    
    // MARK: - Helper Logic
    
    func updateKernel(row: Int, col: Int, value: Double) {
        kernel.set(row, col, value)
        metrics = KernelAnalysisService.analyze(kernel)
        haptics.prepare()
        kernelChangeSubject.send(())
    }
    
    func resetKernel() {
        kernel = .identity()
        metrics = KernelAnalysisService.analyze(kernel)
        outputUIImage = nil
        evaluation = EvaluationResult(similarityPercent: 0, statusText: "Not Started", isComplete: false)
        hasProducedOutput = false
        hasCelebrated = false
        showCompletionPrompt = false
        haptics.prepare()
        lastAnnouncedPercent = nil
    }

    private func rulesPass(challenge: Challenge, metrics: KernelMetrics) -> Bool {
        func approx(_ a: Double, _ b: Double, eps: Double = 0.05) -> Bool {
            abs(a - b) <= eps
        }
        
        switch challenge.id {
        case .smoothing:
            let isAveraging = metrics.positiveCount >= 5
            return !metrics.hasNegative && approx(metrics.sum, 1.0, eps: 0.02) && metrics.symmetry && isAveraging
            
        case .sobelX:
            let sumIsZero = approx(metrics.sum, 0.0, eps: 0.1)
            let biasIsHigh = metrics.directionalBias >= 0.05
            let centerZero = approx(metrics.centerWeight, 0.0, eps: 0.05)
            let midColZero = approx(kernel.get(0, 1), 0.0, eps: 0.05) && approx(kernel.get(1, 1), 0.0, eps: 0.05) && approx(kernel.get(2, 1), 0.0, eps: 0.05)
            let antiSymmetric = approx(kernel.get(0, 0), -kernel.get(0, 2), eps: 0.05) && approx(kernel.get(1, 0), -kernel.get(1, 2), eps: 0.05) && approx(kernel.get(2, 0), -kernel.get(2, 2), eps: 0.05)
            return sumIsZero && metrics.hasNegative && biasIsHigh && centerZero && midColZero && antiSymmetric
            
        case .laplacian:
            let hasBothSigns = metrics.positiveCount > 0 && metrics.negativeCount > 0
            let isZeroSum = approx(metrics.sum, 0.0, eps: 0.001)
            let centerVal = kernel.get(1, 1)
            let neighborsSum = metrics.sum - centerVal
            let patternOK = approx(centerVal, -neighborsSum, eps: 0.001)
            let centerIsPeak = abs(centerVal) >= abs(neighborsSum)
            return isZeroSum && metrics.symmetry && hasBothSigns && patternOK && centerIsPeak && metrics.directionalBias < 0.01
            
        case .sharpening:
            // Sharpening requirement: Sum=1, center dominance, and negative neighbors.
            return metrics.hasNegative && metrics.centerDominance && approx(metrics.sum, 1.0, eps: 0.05)
        }
    }
    
    func confirmPreprocessAndEnterLab() {
        guard let ui = originalUIImage else { return }
        self.processed = PreprocessService.run(image: ui, targetSize: 512, options: preprocess)
        if let p = processed {
            self.originalUIImage = p.displayInput
            computeTargetIfNeeded()
        }
        showPreprocessGate = false
    }

    private func computeTargetIfNeeded() {
        guard let p = processed else { return }
        let target = ConvolutionService.convolve3x3(
            input: p.gray, width: p.width, height: p.height,
            kernel: challenge.idealKernel, normalized01: preprocess.normalizeOn
        )
        self.targetBuffer = target.buffer
    }
}
