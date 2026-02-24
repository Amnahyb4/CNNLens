//
//  ProgressBarView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 02/09/1447 AH.
//

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

                Spacer()

                Text(percentText)
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.text)
            }

            GeometryReader { geo in
                let width = geo.size.width
                let p = CGFloat(max(0, min(100, percent ?? 0))) / 100.0
                let fill = max(28, width * p) // minimum visible fill

                let hasGoal = (goalPercent ?? 0) > 0
                let goalX = hasGoal ? width * CGFloat(min(100, max(0, goalPercent!)) / 100.0) : 0

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)

                    Capsule()
                        .fill(Theme.accent.opacity(percent == nil ? 0.35 : 0.85))
                        .frame(width: percent == nil ? 36 : fill, height: 6)

                    if hasGoal {
                        Rectangle()
                            .fill(Color.white.opacity(0.28))
                            .frame(width: 2, height: 10)
                            .position(x: goalX, y: 3) // centered vertically over the 6pt bar
                            .accessibilityHidden(true)
                    }
                }
            }
            .frame(height: 12) // extra height to accommodate goal tick
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var percentText: String {
        guard let p = percent else { return "—" }
        return String(format: "%.1f%%", p)
    }
}
