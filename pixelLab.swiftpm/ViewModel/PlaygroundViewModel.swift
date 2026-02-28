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
        "Excellent thinker!!",
        "Brilliant work!",
        "Fantastic job!",
        "You nailed it!",
        "Great problem solving!",
        "Outstanding!",
        "Superb reasoning!",
        "Well done!"
    ]
    
    // MARK: - Internal processed + target
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
    
    // MARK: - Gate action
    func confirmPreprocessAndEnterLab() {
        guard let ui = originalUIImage else { return }
        
        self.processed = PreprocessService.run(
            image: ui,
            targetSize: 512,
            options: preprocess
        )
        
        if let p = processed {
            self.originalUIImage = p.displayInput
            computeTargetIfNeeded()
        }
        
        showPreprocessGate = false
        evaluation.statusText = "Not Started"
        hasCelebrated = false
        showCompletionPrompt = false
        completionPhrase = ""
        haptics.prepare()
        lastAnnouncedPercent = nil
        lastAnnouncementAt = .distantPast
    }
    
    // MARK: - User interactions
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
        completionPhrase = ""
        haptics.prepare()
        lastAnnouncedPercent = nil
        lastAnnouncementAt = .distantPast
    }
    
    func applyCurrentKernel() {
        haptics.prepare()
        kernelChangeSubject.send(())
    }
    
    // MARK: - Core pipeline
    private func computeTargetIfNeeded() {
        guard let p = processed else { return }
        let cacheKey = "\(originalAssetName)|\(challenge.id.rawValue)|\(p.optionsKey)"
        if let cached = TargetCache.shared.get(cacheKey) {
            self.targetBuffer = cached.buffer
            return
        }
        
        let target = ConvolutionService.convolve3x3(
            input: p.gray,
            width: p.width,
            height: p.height,
            kernel: challenge.idealKernel,
            normalized01: preprocess.normalizeOn
        )
        
        TargetCache.shared.set(cacheKey, entry: .init(
            buffer: target.buffer,
            image: target.image,
            width: p.width,
            height: p.height
        ))
        self.targetBuffer = target.buffer
    }
    
    private func computeOutputAndEvaluate() {
        guard !showPreprocessGate, let p = processed, let target = targetBuffer else { return }
        
        let out = ConvolutionService.convolve3x3(
            input: p.gray,
            width: p.width,
            height: p.height,
            kernel: kernel,
            normalized01: preprocess.normalizeOn
        )
        
        if !hasProducedOutput { hasProducedOutput = true }
        outputUIImage = out.image
        
        // 1) Use the RECALIBRATED progressive similarity service
        // Flatten 2D kernels to 1D arrays for the service
        let userValues = kernel.values.flatMap { $0 }.map { Float($0) }
        let targetValues = challenge.idealKernel.values.flatMap { $0 }.map { Float($0) }

        let progressiveScore = SimilarityService.nccSimilarityPercent(
            a: out.buffer,
            b: target,
            userKernel: userValues,
            targetKernel: targetValues
        )
        
        // 2) Rules Check
        let rulesOK = rulesPass(challenge: challenge, metrics: metrics)
        
        // 3) Completion Logic (Requires high image accuracy AND math rules)
        let signedNCC = SimilarityService.nccSigned(a: out.buffer, b: target)
        let rawPercentSigned = signedNCC * 100.0
        let meetsThreshold: Bool = {
            switch challenge.id {
            case .sobelX:
                return abs(rawPercentSigned) >= challenge.similarityThreshold
            default:
                return max(0.0, rawPercentSigned) >= challenge.similarityThreshold
            }
        }()
        let complete = meetsThreshold && rulesOK
        
        // 4) Update UI state
        evaluation.similarityPercent = progressiveScore
        evaluation.isComplete = complete
        
        // Trigger Success Celebration
        let wasComplete = evaluation.isComplete
        if !wasComplete && complete && !hasCelebrated && !showCompletionPrompt {
            hasCelebrated = true
            haptics.notificationOccurred(.success)
            haptics.prepare()
            completionPhrase = Self.encouragingPhrases.randomElement() ?? "Great job!"
            showCompletionPrompt = true
            UIAccessibility.post(notification: .screenChanged, argument: "Challenge completed. Choose another challenge or stay here.")
        }
        
        // Contextual Status Text
        if progressiveScore >= 85.0 && !rulesOK {
            evaluation.statusText = "Image looks close! Check Kernel Rules."
        } else {
            evaluation.statusText = complete ? "Completed" : "In Progress"
        }

        announceSimilarityIfNeeded(displayed: progressiveScore, complete: complete)
    }

    private func announceSimilarityIfNeeded(displayed: Double, complete: Bool) {
        let now = Date()
        // 1. Debounce to prevent "announcement overlap"
        guard now.timeIntervalSince(lastAnnouncementAt) >= announceDebounce else { return }
        
        // 2. Round to the nearest 5% step
        let stepRounded = max(0, min(100, Int((displayed / Double(announceStep)).rounded() * Double(announceStep))))
        
        // 3. Only announce if the value has changed significantly OR the user just finished
        if lastAnnouncedPercent != stepRounded || (complete && !hasCelebrated) {
            lastAnnouncedPercent = stepRounded
            lastAnnouncementAt = now
            
            // Refinement: Add a distinctive "Goal Reached" prefix for immediate success confirmation
            let msg = complete
                ? "Challenge Complete! Similarity \(stepRounded) percent. You've matched the kernel pattern."
                : "Similarity \(stepRounded) percent."
                
            UIAccessibility.post(notification: .announcement, argument: msg)
        }
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
            return metrics.hasNegative && metrics.centerDominance && approx(metrics.sum, 1.0, eps: 0.05)
        }
    }
}
