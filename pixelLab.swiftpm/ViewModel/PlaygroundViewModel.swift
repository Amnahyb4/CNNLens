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
    private let announceStep: Int = 5      // announce in 5% steps
    private let announceDebounce: TimeInterval = 1.0 // at most once per second
    
    // MARK: - Init
    init(challenge: Challenge, originalAssetName: String) {
        self.challenge = challenge
        self.originalAssetName = originalAssetName
        self.originalUIImage = ImageLoader.loadUIImage(named: originalAssetName)
        self.evaluation.statusText = "Not Started"
        
        // Prepare haptics early to minimize latency
        haptics.prepare()
        
        // Debounce kernel changes to avoid running convolution while the user is typing
        kernelChangeSubject
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] in
                guard let self else { return }
                // Cancel any in-flight compute task before starting a new one
                self.computeTask?.cancel()
                // Pre-warm haptics just before compute
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
        
        // Fresh session: allow a new celebration and pre-warm haptics
        hasCelebrated = false
        showCompletionPrompt = false
        completionPhrase = ""
        haptics.prepare()

        // Reset announcement tracking
        lastAnnouncedPercent = nil
        lastAnnouncementAt = .distantPast
    }
    
    // MARK: - User interactions
    func updateKernel(row: Int, col: Int, value: Double) {
        kernel.set(row, col, value)
        metrics = KernelAnalysisService.analyze(kernel)
        
        // Pre-warm haptics while scheduling compute
        haptics.prepare()
        
        // Push a change event; debounced sink will compute
        kernelChangeSubject.send(())
    }
    
    func resetKernel() {
        kernel = .identity()
        metrics = KernelAnalysisService.analyze(kernel)
        outputUIImage = nil
        evaluation = EvaluationResult(similarityPercent: 0, statusText: "Not Started", isComplete: false)
        hasProducedOutput = false
        
        // Allow future celebration and prepare haptics
        hasCelebrated = false
        showCompletionPrompt = false
        completionPhrase = ""
        haptics.prepare()

        // Reset announcement tracking
        lastAnnouncedPercent = nil
        lastAnnouncementAt = .distantPast
    }
    
    func applyCurrentKernel() {
        // Route through the same debounced pipeline
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
        
        // 1) Similarity
        let signedNCC = SimilarityService.nccSigned(a: out.buffer, b: target) // [-1, 1]
        let progressiveSim = pow(max(0.0, signedNCC), 2.0) * 100.0           // gentler ramp
        let progressiveMagnitude = pow(abs(signedNCC), 2.0) * 100.0           // gentler ramp for Sobel
        
        // 2) Rules
        let rulesOK = rulesPass(challenge: challenge, metrics: metrics)
        
        // 3) UI progress
        var displayedSimilarity: Double
        let isIdentity = (metrics.positiveCount == 1 && abs(metrics.centerWeight - 1.0) < 0.01)
        
        if isIdentity {
            displayedSimilarity = 5.0
        } else if !rulesOK {
            // Penalize if math rules are broken; cap at 50%
            displayedSimilarity = min(
                (challenge.id == .sobelX) ? progressiveMagnitude : progressiveSim,
                50.0
            )
        } else {
            // For Sobel X, show magnitude so opposite polarity still shows progress.
            displayedSimilarity = (challenge.id == .sobelX) ? progressiveMagnitude : progressiveSim
        }
        
        // 4) Completion (accuracy-first)
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
        
        // Haptics + Prompt only when challenge is completed: trigger exactly on false -> true,
        // and only if we haven't celebrated yet AND no alert is currently visible.
        let wasComplete = evaluation.isComplete
        if !wasComplete && complete && !hasCelebrated && !showCompletionPrompt {
            hasCelebrated = true
            haptics.notificationOccurred(.success)
            haptics.prepare()
            
            // Prepare an encouraging phrase and request UI to show the prompt
            completionPhrase = Self.encouragingPhrases.randomElement() ?? "Great job!"
            showCompletionPrompt = true

            // Announce screen change for VoiceOver users
            UIAccessibility.post(notification: .screenChanged, argument: "Challenge completed. Choose another challenge or stay here.")
        }
        
        evaluation.similarityPercent = displayedSimilarity
        evaluation.isComplete = complete
        
        // Contextual Status Text
        // Use the user-visible similarity for messaging so it won't trigger while capped at 50%.
        if displayedSimilarity >= 90.0 && !rulesOK {
            evaluation.statusText = "Image looks close! Check Kernel Rules."
        } else {
            evaluation.statusText = complete ? "Completed" : "In Progress"
        }

        // Accessibility: Announce similarity in steps and when hitting the goal
        announceSimilarityIfNeeded(displayed: displayedSimilarity, complete: complete)
    }

    private func announceSimilarityIfNeeded(displayed: Double, complete: Bool) {
        // Throttle announcements
        let now = Date()
        guard now.timeIntervalSince(lastAnnouncementAt) >= announceDebounce else { return }

        // Round to step increments to avoid chatter
        let stepRounded = max(0, min(100, Int((displayed / Double(announceStep)).rounded() * Double(announceStep))))
        if lastAnnouncedPercent != stepRounded {
            lastAnnouncedPercent = stepRounded
            lastAnnouncementAt = now

            if complete {
                UIAccessibility.post(notification: .announcement, argument: "Similarity \(stepRounded) percent. Goal reached.")
            } else {
                UIAccessibility.post(notification: .announcement, argument: "Similarity \(stepRounded) percent.")
            }
        }
    }
    
    // MARK: - Strict Mathematical Rules
    private func rulesPass(challenge: Challenge, metrics: KernelMetrics) -> Bool {
        func approx(_ a: Double, _ b: Double, eps: Double = 0.05) -> Bool {
            abs(a - b) <= eps
        }
        
        switch challenge.id {
        case .smoothing:
            let isAveraging = metrics.positiveCount >= 5
            return !metrics.hasNegative &&
            approx(metrics.sum, 1.0, eps: 0.02) &&
            metrics.symmetry &&
            isAveraging
            
        case .sobelX:
            // Enforce canonical Sobel X structure:
            // 1) Zero-sum
            // 2) Negative weights present
            // 3) Directional bias (horizontal) high
            // 4) Middle column is (approximately) all zeros
            // 5) Center is ~0
            // 6) Horizontal anti-symmetry: left column == - right column, row-wise
            let sumIsZero = approx(metrics.sum, 0.0, eps: 0.1)
            let biasIsHigh = metrics.directionalBias >= 0.05
            let centerZero = approx(metrics.centerWeight, 0.0, eps: 0.05)
            let midColZero =
                approx(kernel.get(0, 1), 0.0, eps: 0.05) &&
                approx(kernel.get(1, 1), 0.0, eps: 0.05) &&
                approx(kernel.get(2, 1), 0.0, eps: 0.05)
            let antiSymmetric =
                approx(kernel.get(0, 0), -kernel.get(0, 2), eps: 0.05) &&
                approx(kernel.get(1, 0), -kernel.get(1, 2), eps: 0.05) &&
                approx(kernel.get(2, 0), -kernel.get(2, 2), eps: 0.05)
            
            return sumIsZero &&
                   metrics.hasNegative &&
                   biasIsHigh &&
                   centerZero &&
                   midColZero &&
                   antiSymmetric
            
        case .laplacian:
            let hasBothSigns = metrics.positiveCount > 0 && metrics.negativeCount > 0
            let isZeroSum = approx(metrics.sum, 0.0, eps: 0.001) //
            
            let centerVal = kernel.get(1, 1)
            let neighborsSum = metrics.sum - centerVal //
            
            // ENHANCED RULE: Center must balance neighbors AND be a significant peak
            let patternOK = approx(centerVal, -neighborsSum, eps: 0.001) //
            let centerIsPeak = abs(centerVal) >= abs(neighborsSum) //
            
            return isZeroSum && metrics.symmetry && hasBothSigns && patternOK && centerIsPeak && metrics.directionalBias < 0.01
            
        case .sharpening:
            // 1. Must have negatives to find edges
            // 2. Center must be the largest positive value
            // 3. Total sum must be 1.0 (with 0.05 epsilon)
            return metrics.hasNegative &&
                   metrics.centerDominance &&
                   approx(metrics.sum, 1.0, eps: 0.05)
        }
    }
}
