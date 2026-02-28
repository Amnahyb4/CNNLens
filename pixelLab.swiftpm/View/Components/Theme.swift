
import SwiftUI

enum Theme {
    // Dark blue background (consistent everywhere)
    static let bgTop = Color(red: 0.03, green: 0.05, blue: 0.10)
    static let bgBottom = Color(red: 0.02, green: 0.03, blue: 0.07)

    // Card surface (dark, slightly lifted)
    static let card = Color.white.opacity(0.07)
    static let cardSelected = Color.white.opacity(0.10)

    // Text (slightly increased for better contrast on dark backgrounds)
    static let text = Color.white.opacity(0.97)
    static let secondary = Color.white.opacity(0.72)
    static let tertiary = Color.white.opacity(0.55)

    // Accent (Apple-ish calm blue)
    static let accent = Color(red: 0.20, green: 0.52, blue: 1.00)

    // Borders (slightly stronger for clearer separation)
    static let border = Color.white.opacity(0.12)

    // Surfaces
    static let surface = Color.white.opacity(0.08)
    static let surface2 = Color.white.opacity(0.06)

    // If you adopt materials, consider providing an opaque fallback for Reduce Transparency users:
    // static let materialFallback = Color(red: 0.08, green: 0.10, blue: 0.16)
    // Then in views using materials, switch to this color when Reduce Transparency is enabled.
}
