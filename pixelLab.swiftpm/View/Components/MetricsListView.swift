import SwiftUI

struct MetricsListView: View {
    let metrics: KernelMetrics

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Marked as a header for rotor navigation
            VStack(alignment: .leading, spacing: 10) {
                Text("LIVE METRICS")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.tertiary)
                    .tracking(0.7)
                    .accessibilityAddTraits(.isHeader)

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 12) {
                row("Kernel Sum", String(format: "%.2f", metrics.sum))
                divider()
                row("Negative Values", metrics.hasNegative ? "Yes" : "No")
                divider()
                row("Symmetry", metrics.symmetry ? "Yes" : "No")
                divider()
                // Refinement: Likely Behavior is highlighted with the accent color
                row("Likely Behavior", metrics.likelyBehavior, valueColor: Theme.accent.opacity(0.95))
            }
        }
        .padding(18)
        .background(reduceTransparency ? Theme.surfaceOpaque : Theme.surfaceTranslucent) // Reactive Reduce Transparency
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        // Groups the entire list for easier navigation
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Current kernel metrics")
    }

    private func row(_ label: String, _ value: String, valueColor: Color = Theme.text) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(valueColor)
        }
        // Combines label and value into a single, cohesive announcement
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }

    private func divider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .accessibilityHidden(true) // Hides decorative lines
    }
}
