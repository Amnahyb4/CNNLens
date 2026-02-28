import Foundation

enum SimilarityService {

    // Internal helper to compute NCC in [-1, 1]
    private static func ncc(_ a: [Float], _ b: [Float]) -> Double? {
        guard a.count == b.count, !a.isEmpty else { return nil }

        var meanA: Double = 0
        var meanB: Double = 0
        let n = Double(a.count)

        for i in 0..<a.count {
            meanA += Double(a[i])
            meanB += Double(b[i])
        }
        meanA /= n
        meanB /= n

        var numerator: Double = 0
        var denA: Double = 0
        var denB: Double = 0

        for i in 0..<a.count {
            let diffA = Double(a[i]) - meanA
            let diffB = Double(b[i]) - meanB
            numerator += (diffA * diffB)
            denA += (diffA * diffA)
            denB += (diffB * diffB)
        }

        let denominator = sqrt(denA * denB)
        if denominator == 0 { return nil }

        return numerator / denominator
    }

    /// Signed NCC in [-1, 1]. Returns 0 on invalid input.
    static func nccSigned(a: [Float], b: [Float]) -> Double {
        ncc(a, b) ?? 0.0
    }

    /// Progressive, UI-friendly similarity percent (0...100).
    /// Recalibrated for high-responsiveness and immediate user feedback.
    static func nccSimilarityPercent(
        a: [Float],
        b: [Float],
        userKernel: [Float],
        targetKernel: [Float]
    ) -> Double {
        let ncc = nccSigned(a: a, b: b)
        let correlation = max(0.0, ncc)
        
        // 1. Image-based progress (Linear Scaling)
        // By removing the power (pow) entirely, we make the progress bar
        // track the visual change much more aggressively.
        let imageScore = correlation * 60.0
        
        // 2. Kernel-matching bonus (Increased Weight: 40%)
        // This provides a massive boost for simply putting numbers in the right direction.
        // It turns the grid into a rewarding interactive puzzle.
        var matchPoints: Double = 0
        for i in 0..<userKernel.count {
            let u = userKernel[i]
            let t = targetKernel[i]
            
            // Check if signs match or if both are zero
            if (u > 0 && t > 0) || (u < 0 && t < 0) || (u == 0 && t == 0) {
                matchPoints += 1
            }
        }
        
        let kernelBonus = (matchPoints / Double(userKernel.count)) * 40.0
        
        // Combine scores for a total that reaches 100% when both match.
        // This hybrid approach ensures the user never feels "stuck".
        let finalScore = imageScore + kernelBonus
        return min(100.0, finalScore)
    }
}
