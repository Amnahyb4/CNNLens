
import Foundation

@MainActor
final class ChallengeSelectionViewModel: ObservableObject {

    // List shown in Screen 3
    @Published private(set) var challenges: [Challenge] = ChallengeID.allCases.map {
        ChallengeFactory.make($0)
    }

    // Selected challenge
    @Published var selected: Challenge? = nil

    var canContinue: Bool { selected != nil }

    func select(_ challenge: Challenge) {
        selected = challenge
    }

    func clearSelection() {
        selected = nil
    }
}

