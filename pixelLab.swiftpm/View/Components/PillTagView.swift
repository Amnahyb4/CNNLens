import SwiftUI

struct PillTagView: View {
    let text: String

    var body: some View {
        Text(text)
            // Weight increased to .semibold to maintain legibility when scaled up
            .font(.subheadline.weight(.semibold))
            // Using Theme.text (97% white) for better contrast
            .foregroundStyle(Theme.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            // Use Theme.surface2 to support the Reduce Transparency fallback
            .background(Theme.surface2)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Theme.border, lineWidth: 1) // Adds definition on dark backgrounds
            )
            .accessibilityLabel("Category: \(text)")
    }
}
