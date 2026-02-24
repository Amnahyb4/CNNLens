
import Foundation

struct Kernel: Equatable {
    // row-major 3x3
    var values: [[Double]] = Array(repeating: Array(repeating: 0, count: 3), count: 3)

    static func zeros() -> Kernel { Kernel() }

    static func identity() -> Kernel {
        var k = Kernel.zeros()
        k.values[1][1] = 1
        return k
    }

    mutating func set(_ row: Int, _ col: Int, _ value: Double) {
        guard (0..<3).contains(row), (0..<3).contains(col) else { return }
        values[row][col] = value
    }

    func get(_ row: Int, _ col: Int) -> Double {
        guard (0..<3).contains(row), (0..<3).contains(col) else { return 0 }
        return values[row][col]
    }
}

