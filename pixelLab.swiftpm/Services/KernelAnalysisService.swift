import Foundation

enum KernelAnalysisService {
    static func analyze(_ kernel: Kernel) -> KernelMetrics {
        let flat = kernel.values.flatMap { $0 }
        let sum = flat.reduce(0, +)
        let totalAbs = flat.map { abs($0) }.reduce(0, +)

        let positiveCount = flat.filter { $0 > 0 }.count
        let negativeCount = flat.filter { $0 < 0 }.count
        let hasNeg = negativeCount > 0

        // ISOTROPIC SYMMETRY (Required for Laplacian)
        let isVerticalSym = approxEq(kernel.get(0, 1), kernel.get(2, 1))
        let isHorizontalSym = approxEq(kernel.get(1, 0), kernel.get(1, 2))
        let isDiagonal1 = approxEq(kernel.get(0, 0), kernel.get(2, 2))
        let isDiagonal2 = approxEq(kernel.get(0, 2), kernel.get(2, 0))
        
        let cornersEqual = approxEq(kernel.get(0, 0), kernel.get(0, 2)) &&
                           approxEq(kernel.get(0, 0), kernel.get(2, 0)) &&
                           approxEq(kernel.get(0, 0), kernel.get(2, 2))
        
        let neighborsEqual = approxEq(kernel.get(0, 1), kernel.get(1, 0)) &&
                             approxEq(kernel.get(0, 1), kernel.get(1, 2)) &&
                             approxEq(kernel.get(0, 1), kernel.get(2, 1))

        let sym = isVerticalSym && isHorizontalSym && isDiagonal1 && isDiagonal2 && cornersEqual && neighborsEqual

        let center = kernel.get(1, 1)
        let neighborAbsSum = flat.enumerated().reduce(0.0) { acc, elem in
            let (idx, val) = elem
            if idx == 4 { return acc }
            return acc + abs(val)
        }
        let centerDominance = abs(center) > neighborAbsSum

        // Signed directional imbalance (captures Sobel X/Y correctly)
        // For Sobel X: strong left-vs-right signed difference, near-zero top-vs-bottom
        let leftSigned = kernel.get(0, 0) + kernel.get(1, 0) + kernel.get(2, 0)
        let rightSigned = kernel.get(0, 2) + kernel.get(1, 2) + kernel.get(2, 2)
        let topSigned = kernel.get(0, 0) + kernel.get(0, 1) + kernel.get(0, 2)
        let bottomSigned = kernel.get(2, 0) + kernel.get(2, 1) + kernel.get(2, 2)

        let lrSignedImbalance = abs(rightSigned - leftSigned)
        let tbSignedImbalance = abs(bottomSigned - topSigned)

        // Normalize by total absolute weight to keep [0, 1]-ish scale
        let directionalBias: Double = totalAbs > 0 ? (lrSignedImbalance + tbSignedImbalance) / totalAbs : 0

        let behavior: String = {
            if !hasNeg && approxEq(sum, 1.0, eps: 0.1) { return "Low-Pass" }
            if approxEq(sum, 0.0, eps: 0.1) && hasNeg {
                // Sobel is directional and anti-symmetric; Laplacian is isotropic and symmetric.
                return (directionalBias < 0.05 && sym) ? "Edge/Isotropic" : "Edge/Directional"
            }
            if hasNeg && centerDominance && approxEq(sum, 1.0, eps: 0.1) { return "Sharpening" }
            return "Custom"
        }()

        return KernelMetrics(
            sum: sum,
            hasNegative: hasNeg,
            symmetry: sym,
            likelyBehavior: behavior,
            positiveCount: positiveCount,
            negativeCount: negativeCount,
            centerWeight: center,
            neighborAbsSum: neighborAbsSum,
            centerDominance: centerDominance,
            directionalBias: directionalBias
        )
    }

    // Standardized epsilon for the whole app
    static func approxEq(_ a: Double, _ b: Double, eps: Double = 0.05) -> Bool {
        abs(a - b) <= eps
    }
}
