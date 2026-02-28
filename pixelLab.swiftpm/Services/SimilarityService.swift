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

    /// Progressive, UI-friendly similarity percent (0...100) using NCC^4.
    /// Keeps the progress bar from jumping to high values too early.
    static func nccSimilarityPercent(a: [Float], b: [Float]) -> Double {
        let ncc = nccSigned(a: a, b: b)
        let correlation = max(0.0, ncc)
        let progressiveScore = pow(correlation, 4.0)
        return progressiveScore * 100.0
    }
}
