import SwiftUI

struct ChallengeRowCard: View {
    let challenge: Challenge
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                // Main Content: Title and Description
                VStack(alignment: .leading, spacing: 10) {
                    Text(challenge.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.text)

                    Text(challenge.oneLine)
                        .font(.body)
                        .foregroundStyle(Theme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 12)

                // Metadata Tag: Visual only, hidden from VoiceOver to reduce noise
                PillTagView(text: challenge.tag)
                    .accessibilityHidden(true)
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            // UI Logic: Supports 'Reduce Transparency' via Theme.surface
            .background(isSelected ? Theme.accent.opacity(0.12) : Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(isSelected ? Theme.accent : Theme.border,
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        // Accessibility Suite
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(challenge.title) challenge")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to select the \(challenge.title) concept.")
    }
}
