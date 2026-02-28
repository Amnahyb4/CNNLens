
import SwiftUI

struct ChallengeInfoCard: View {
    // Header title shown on the card
    let title: String
    // Concept/challenge name used inside the info popover/sheet
    let conceptTitle: String

    let goal: String
    let hints: [String]
    let criteria: [String]
    let statusText: String
    let educationalText: String

    // Keep a taller box so it feels balanced on iPad; can be overridden by caller.
    var minHeight: CGFloat = 680

    @State private var showInfo: Bool = false
    @Environment(\.horizontalSizeClass) private var hSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header (Title Case + info button)
            HStack(spacing: 10) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Theme.text)

                Spacer()

                infoButton
            }

            // Divider (slightly clearer for legibility)
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            // Goal
            Text(goal)
                .font(.callout)
                .foregroundStyle(Theme.secondary)
                .lineSpacing(3)

            // Hints
            sectionHeader("HINTS")

            VStack(alignment: .leading, spacing: 10) {
                ForEach(hints, id: \.self) { h in
                    hintRow(text: h)
                }
            }

            // Criteria
            sectionHeader("COMPLETION CRITERIA")

            VStack(alignment: .leading, spacing: 10) {
                ForEach(criteria, id: \.self) { c in
                    criteriaRow(text: c)
                }
            }

            Spacer(minLength: 8)

            // Status chip
            statusChip(statusText)
        }
        .padding(18)
        .frame(minHeight: minHeight, alignment: .top)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Info button with adaptive presentation
    private var infoButton: some View {
        let isPadLike = (hSize == .regular)

        return Button {
            showInfo = true
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold)) // small visual size
                .foregroundStyle(Theme.accent)
                .frame(width: 44, height: 44) // HIG: minimum hit target
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Learn more about this concept")
        // iPad: Popover (contextual, lightweight, system chrome)
        .popover(isPresented: Binding(
            get: { showInfo && isPadLike },
            set: { showInfo = $0 }
        )) {
            InfoPopoverContent(
                title: conceptTitle,               // show selected challenge name here
                educationalText: educationalText
            )
            .frame(width: 400) // typical popover width; feels balanced
        }
        // iPhone: Bottom sheet (detents)
        .sheet(isPresented: Binding(
            get: { showInfo && !isPadLike },
            set: { showInfo = $0 }
        )) {
            ChallengeInfoSheetView(
                title: conceptTitle,               // and here
                educationalText: educationalText
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Subviews

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Theme.tertiary.opacity(1.0))
            .tracking(0.7)
            .padding(.top, 2)
            .accessibilityAddTraits(.isHeader)
    }

    private func hintRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Theme.accent.opacity(0.9))
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.callout)
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func criteriaRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle")
                .foregroundStyle(Theme.tertiary)
                .font(.system(size: 12))
                .padding(.top, 5)

            Text(text)
                .font(.callout)
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func statusChip(_ text: String) -> some View {
        // Determine color based on status text
        let lower = text.lowercased()
        let isCompleted = lower.contains("completed")
        let isNotStarted = lower.contains("not started")
        let isInProgress = lower.contains("in progress")

        let statusColor: Color = {
            if isCompleted { return .green }
            if isInProgress { return .yellow }
            if isNotStarted { return Theme.secondary }
            // fallback for any other custom statuses
            return Theme.secondary
        }()

        return HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(statusColor)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Theme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .accessibilityLabel("Status: \(text)")
    }
}

// MARK: - Popover content (iPad)

private struct InfoPopoverContent: View {
    let title: String
    let educationalText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Concept")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Divider()

            Text(title) // Selected challenge name
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(educationalText)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(20)
        // No custom background/shape: use system popover chrome for HIG consistency.
        // Dismiss by tapping outside the popover (standard behavior).
    }
}
