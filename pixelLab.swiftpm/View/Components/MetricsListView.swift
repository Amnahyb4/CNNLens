
import SwiftUI

struct MetricsListView: View {
    let metrics: KernelMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Larger header
            VStack(alignment: .leading, spacing: 10) {
                Text("LIVE METRICS")
                    .font(.subheadline.weight(.semibold))   // increased for visibility
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
                row("Likely Behavior", metrics.likelyBehavior, valueColor: Theme.accent.opacity(0.95))
            }
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Live metrics")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label)")
        .accessibilityValue("\(value)")
    }

    private func divider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}
