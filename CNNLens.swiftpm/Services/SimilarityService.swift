
import Foundation

enum SimilarityService {

    /// Mean Squared Error (MSE) mapped to similarity %.
    /// For normalized 0..1 buffers: mse ∈ [0, 1]. similarity = (1 - mse) * 100.
    static func mseSimilarityPercent(a: [Float], b: [Float]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0 }

        var sum: Double = 0
        for i in 0..<a.count {
            let d = Double(a[i] - b[i])
            sum += d * d
        }

        let mse = sum / Double(a.count)
        let sim = max(0.0, min(1.0, 1.0 - mse))
        return sim * 100.0
    }
}
