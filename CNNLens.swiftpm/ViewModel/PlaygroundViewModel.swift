
import SwiftUI
import UIKit

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
    @Published var outputUIImage: UIImage? = nil // Option B: nil until first output is produced

    // MARK: - Internal processed + target
    private var processed: PreprocessService.Result? = nil
    private var targetBuffer: [Float]? = nil

    private var hasProducedOutput = false
    private var computeTask: Task<Void, Never>? = nil

    // MARK: - Init
    init(challenge: Challenge, originalAssetName: String) {
        self.challenge = challenge
        self.originalAssetName = originalAssetName

        self.originalUIImage = ImageLoader.loadUIImage(named: originalAssetName)
        self.evaluation.statusText = "Not Started"
    }

    // MARK: - Gate action
    func confirmPreprocessAndEnterLab() {
        guard let ui = originalUIImage else { return }

        // Preprocess ON (Resize + Normalize + Grayscale) — using 512 for iPad quality
        self.processed = PreprocessService.run(
            image: ui,
            targetSize: 512,
            options: preprocess
        )

        // Show processed input in Original panel (consistent display)
        if let p = processed {
            self.originalUIImage = p.displayInput
            computeTargetIfNeeded()
        }

        showPreprocessGate = false
        evaluation.statusText = "Not Started"
    }

    // MARK: - User interactions
    func updateKernel(row: Int, col: Int, value: Double) {
        kernel.set(row, col, value)
        metrics = KernelAnalysisService.analyze(kernel)

        // Live compute (debounced so typing feels smooth)
        computeTask?.cancel()
        computeTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 90_000_000) // ~90ms
            await self?.computeOutputAndEvaluate()
        }
    }

    func resetKernel() {
        kernel = .identity()
        metrics = KernelAnalysisService.analyze(kernel)
        outputUIImage = nil
        evaluation = EvaluationResult(similarityPercent: nil, statusText: "Not Started", isComplete: false)
        hasProducedOutput = false
    }

    // Manual trigger (for the “Apply Kernel” button)
    func applyCurrentKernel() {
        computeTask?.cancel()
        computeOutputAndEvaluate()
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
        guard !showPreprocessGate else { return }
        guard let p = processed else { return }

        if targetBuffer == nil { computeTargetIfNeeded() }
        guard let target = targetBuffer else { return }

        let out = ConvolutionService.convolve3x3(
            input: p.gray,
            width: p.width,
            height: p.height,
            kernel: kernel,
            normalized01: preprocess.normalizeOn
        )

        // Option B: output appears only after first meaningful computation
        if !hasProducedOutput { hasProducedOutput = true }
        outputUIImage = out.image

        // Similarity vs target (MSE -> %)
        let sim = SimilarityService.mseSimilarityPercent(a: out.buffer, b: target)

        // Rule checks (non-cheaty)
        let rulesOK = rulesPass(challenge: challenge, metrics: metrics)

        let complete = (sim >= challenge.similarityThreshold) && rulesOK
        evaluation.similarityPercent = sim
        evaluation.isComplete = complete
        evaluation.statusText = complete ? "Completed" : "Not Complete"
    }

    // MARK: - Rules (tightened + educational)
    private func rulesPass(challenge: Challenge, metrics: KernelMetrics) -> Bool {
        // Helpers
        func approx(_ a: Double, _ b: Double, eps: Double) -> Bool { abs(a - b) <= eps }

        switch challenge.id {

        case .smoothing:
            // Positive weights only, sum ~ 1, symmetric kernel (isotropic blur)
            return !metrics.hasNegative
                && approx(metrics.sum, 1.0, eps: 0.06)
                && metrics.symmetry

        case .sobelX:
            // Directional first-derivative: zero-sum, negatives present, not symmetric, noticeable directional bias
            return approx(metrics.sum, 0.0, eps: 0.10)
                && metrics.hasNegative
                && !metrics.symmetry
                && metrics.directionalBias >= 0.25

        case .laplacian:
            // Second derivative, isotropic: zero-sum, positives and negatives present, symmetric, low directional bias
            let hasPosAndNeg = (metrics.positiveCount > 0 && metrics.negativeCount > 0)
            return approx(metrics.sum, 0.0, eps: 0.10)
                && hasPosAndNeg
                && metrics.symmetry
                && metrics.directionalBias <= 0.10

        case .sharpening:
            // High-pass with strong center: negatives present around, center weight dominates neighbors
            return metrics.hasNegative
                && metrics.centerDominance
        }
    }
}
