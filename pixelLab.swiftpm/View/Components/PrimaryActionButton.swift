import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String?
    let isEnabled: Bool
    let action: () -> Void

    init(
        title: String,
        systemImage: String? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                        .accessibilityHidden(true) // Explicitly hide decorative icon
                }
                Text(title)
                    .font(.headline.weight(.semibold))
            }
            .foregroundStyle(Color.white)
            // Increased hit area for professional iPad lab look
            .frame(maxWidth: .infinity, minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.accent) // Integrated with global theme
                .opacity(isEnabled ? 1.0 : 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .disabled(!isEnabled)
        // Groups the entire button for a single, clear announcement
        .accessibilityLabel(title)
        .accessibilityHint(isEnabled ? "Double tap to continue." : "Select a challenge above to enable this action.")
    }
}
