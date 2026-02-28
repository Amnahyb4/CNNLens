import SwiftUI

struct ChallengeInfoCard: View {
    let title: String
    let conceptTitle: String
    let goal: String
    let hints: [String]
    let criteria: [String]
    let statusText: String
    let educationalText: String
    var minHeight: CGFloat = 680

    @State private var showInfo: Bool = false
    @Environment(\.horizontalSizeClass) private var hSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header: Added header trait for better rotor navigation
            HStack(spacing: 10) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Theme.text)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                infoButton
            }

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .accessibilityHidden(true)

            Text(goal)
                .font(.callout)
                .foregroundStyle(Theme.secondary)
                .lineSpacing(3)
                .accessibilityLabel("Goal: \(goal)")

            sectionHeader("HINTS")

            VStack(alignment: .leading, spacing: 10) {
                ForEach(hints, id: \.self) { h in
                    hintRow(text: h)
                }
            }

            sectionHeader("COMPLETION CRITERIA")

            VStack(alignment: .leading, spacing: 10) {
                ForEach(criteria, id: \.self) { c in
                    criteriaRow(text: c)
                }
            }

            Spacer(minLength: 8)

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

    private var infoButton: some View {
        let isPadLike = (hSize == .regular)

        return Button {
            showInfo = true
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Learn more about \(conceptTitle)")
        .popover(isPresented: Binding(
            get: { showInfo && isPadLike },
            set: { showInfo = $0 }
        )) {
            // This is now in-scope below
            InfoPopoverContent(
                title: conceptTitle,
                educationalText: educationalText
            )
            .frame(width: 400)
        }
        .sheet(isPresented: Binding(
            get: { showInfo && !isPadLike },
            set: { showInfo = $0 }
        )) {
            ChallengeInfoSheetView(
                title: conceptTitle,
                educationalText: educationalText
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

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
                .accessibilityHidden(true)

            Text(text)
                .font(.callout)
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func criteriaRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "circle")
                .foregroundStyle(Theme.tertiary)
                .font(.system(size: 12))
                .padding(.top, 5)
                .accessibilityHidden(true)

            Text(text)
                .font(.callout)
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func statusChip(_ text: String) -> some View {
        let lower = text.lowercased()
        let isCompleted = lower.contains("completed")
        let isInProgress = lower.contains("in progress")

        let statusColor: Color = {
            if isCompleted { return .green }
            if isInProgress { return .yellow }
            return Theme.secondary
        }()

        return HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

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
        .accessibilityLabel("Challenge Status: \(text)")
    }
}

// MARK: - Missing Subviews (Fixed Scope)

private struct InfoPopoverContent: View {
    let title: String
    let educationalText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Concept")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            Divider()

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(educationalText)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(20)
    }
}
