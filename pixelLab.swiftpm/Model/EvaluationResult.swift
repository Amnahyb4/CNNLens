
import Foundation

struct EvaluationResult: Equatable {
    var similarityPercent: Double? = nil // nil until first output exists
    var statusText: String = "Not Started"
    var isComplete: Bool = false
}
