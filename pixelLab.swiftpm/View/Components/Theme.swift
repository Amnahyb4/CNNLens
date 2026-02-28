import SwiftUI
import UIKit

enum Theme {
    // MARK: - Core Backgrounds
    // Dark blue background (consistent across the app)
    static let bgTop = Color(red: 0.03, green: 0.05, blue: 0.10)
    static let bgBottom = Color(red: 0.02, green: 0.03, blue: 0.07)

    // MARK: - Surfaces & Cards
    // Smart surface logic: Provides an opaque fallback for 'Reduce Transparency' users
    @MainActor
    static var surface: Color {
        UIAccessibility.isReduceTransparencyEnabled
            ? Color(red: 0.08, green: 0.10, blue: 0.16)
            : Color.white.opacity(0.08)
    }
    
    @MainActor
    static var surface2: Color {
        UIAccessibility.isReduceTransparencyEnabled
            ? Color(red: 0.06, green: 0.08, blue: 0.14)
            : Color.white.opacity(0.06)
    }

    // Card states (dark, slightly lifted for depth)
    static let card = Color.white.opacity(0.07)
    static let cardSelected = Color.white.opacity(0.10)

    // MARK: - Typography 
    // High-contrast primary text for better readability
    static let text = Color.white.opacity(0.97)
    
    // Secondary information with a 72% alpha to create visual hierarchy
    static let secondary = Color.white.opacity(0.72)
    
    // Tertiary/Header text with 55% alpha
    static let tertiary = Color.white.opacity(0.55)

    // MARK: - UI Accents
    // Apple-inspired calm blue for primary actions and highlights
    static let accent = Color(red: 0.20, green: 0.52, blue: 1.00)

    // MARK: - Borders & Dividers
    // Stronger opacity for clearer separation of lab columns
    static let border = Color.white.opacity(0.12)
}
