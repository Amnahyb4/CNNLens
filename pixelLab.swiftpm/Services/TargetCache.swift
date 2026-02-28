
import UIKit

@MainActor
final class TargetCache {
    static let shared = TargetCache()

    struct Entry {
        let buffer: [Float]
        let image: UIImage
        let width: Int
        let height: Int
    }

    private var store: [String: Entry] = [:]

    func get(_ key: String) -> Entry? { store[key] }
    func set(_ key: String, entry: Entry) { store[key] = entry }
}
