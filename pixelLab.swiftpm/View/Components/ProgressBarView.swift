import SwiftUI

struct ProgressBarView: View {
    let label: String
    let percent: Double? // nil => show “—”
    var goalPercent: Double? = nil // optional goal marker (e.g., 90%)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header row + trailing value
            HStack {
                Text(label.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.tertiary)
                    .tracking(0.6)
                    .accessibilityHidden(true)

                Spacer()

                Text(percentText)
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.text)
                    .accessibilityHidden(true)
            }

            GeometryReader { geo in
                let width = geo.size.width
                let p = CGFloat(max(0, min(100, percent ?? 0))) / 100.0
                let fill = max(28, width * p) // minimum visible fill

                let hasGoal = (goalPercent ?? 0) > 0
                let goalX = hasGoal ? width * CGFloat(min(100, max(0, goalPercent!)) / 100.0) : 0

                ZStack(alignment: .leading) {
                    // Background Track
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                        .accessibilityHidden(true)

                    // Progress Fill
                    Capsule()
                        .fill(Theme.accent.opacity(percent == nil ? 0.35 : 0.85))
                        .frame(width: percent == nil ? 36 : fill, height: 6)
                        .accessibilityHidden(true)

                    if hasGoal {
                        // Visual Goal Marker
                        Rectangle()
                            .fill(Color.white.opacity(0.28))
                            .frame(width: 2, height: 10)
                            .position(x: goalX, y: 3)
                            .accessibilityHidden(true)
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(18)
        .background(Theme.surface) // Supports Reduce Transparency fallback
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        // Refinement: Combines label and value for a clear, single-swipe announcement
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label.capitalized))
        .accessibilityValue(Text(accessibilityPercentText))
    }

    private var percentText: String {
        guard let p = percent else { return "—" }
        return String(format: "%.1f%%", p)
    }

    private var accessibilityPercentText: String {
        guard let p = percent else { return "No value" }
        let current = String(format: "%.1f percent", p)
        
        // Refinement: Announce the goal if one is set
        if let goal = goalPercent, goal > 0 {
            return "\(current). Goal is \(Int(goal)) percent."
        }
        return current
    }
}
