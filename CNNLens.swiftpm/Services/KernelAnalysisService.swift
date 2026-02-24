
import Foundation

enum KernelAnalysisService {

    static func analyze(_ kernel: Kernel) -> KernelMetrics {
        let flat = kernel.values.flatMap { $0 }
        let sum = flat.reduce(0, +)

        let positiveCount = flat.filter { $0 > 0 }.count
        let negativeCount = flat.filter { $0 < 0 }.count
        let hasNeg = negativeCount > 0

        // symmetry check for 3x3 (mirror across center)
        let sym =
            approxEq(kernel.get(0,0), kernel.get(2,2)) &&
            approxEq(kernel.get(0,1), kernel.get(2,1)) &&
            approxEq(kernel.get(0,2), kernel.get(2,0)) &&
            approxEq(kernel.get(1,0), kernel.get(1,2))

        // Center vs neighbors
        let center = kernel.get(1,1)
        let neighborAbsSum = flat.enumerated().reduce(0.0) { acc, elem in
            let (idx, val) = elem
            if idx == 4 { // center index in row-major 3x3
                return acc
            }
            return acc + abs(val)
        }
        let centerDominance = abs(center) > neighborAbsSum

        // Directionality (left-right and top-bottom imbalance normalized by total abs sum)
        let totalAbs = flat.map { abs($0) }.reduce(0, +)
        let leftSum = abs(kernel.get(0,0)) + abs(kernel.get(1,0)) + abs(kernel.get(2,0))
        let rightSum = abs(kernel.get(0,2)) + abs(kernel.get(1,2)) + abs(kernel.get(2,2))
        let topSum = abs(kernel.get(0,0)) + abs(kernel.get(0,1)) + abs(kernel.get(0,2))
        let bottomSum = abs(kernel.get(2,0)) + abs(kernel.get(2,1)) + abs(kernel.get(2,2))

        let lrImbalance = abs(leftSum - rightSum)
        let tbImbalance = abs(topSum - bottomSum)

        let directionalBias: Double = totalAbs > 0 ? (lrImbalance + tbImbalance) / totalAbs : 0

        let behavior: String = {
            if !hasNeg && approxEq(sum, 1.0, eps: 0.06) { return "Low-Pass" }
            if approxEq(sum, 0.0, eps: 0.08) && hasNeg {
                return directionalBias > 0.2 ? "Edge/Directional" : "Edge/Isotropic"
            }
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

    static func approxEq(_ a: Double, _ b: Double, eps: Double = 0.001) -> Bool {
        abs(a - b) <= eps
    }
}
