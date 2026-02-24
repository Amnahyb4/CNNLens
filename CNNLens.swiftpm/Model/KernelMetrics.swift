
import Foundation

struct KernelMetrics: Equatable {
    // Existing
    var sum: Double = 0
    var hasNegative: Bool = false
    var symmetry: Bool = false
    var likelyBehavior: String = "Custom"

    // New helpers for more robust rules
    var positiveCount: Int = 0
    var negativeCount: Int = 0

    // Center vs neighbors
    var centerWeight: Double = 0
    var neighborAbsSum: Double = 0
    var centerDominance: Bool = false // true if |center| > sum(|neighbors|)

    // Directionality (0 = isotropic, higher = more directional)
    // Computed as normalized left-vs-right + top-vs-bottom imbalance.
    var directionalBias: Double = 0
}
