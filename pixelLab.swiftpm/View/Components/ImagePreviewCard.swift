import SwiftUI

struct ImagePreviewCard: View {
    let title: String
    let image: UIImage?
    let emptyStateTitle: String
    let emptyStateSubtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header row + divider (larger title)
            VStack(alignment: .leading, spacing: 10) {
                Text(title.uppercased())
                    .font(.subheadline.weight(.semibold))   // increased for visibility
                    .foregroundStyle(Theme.tertiary)
                    .tracking(0.7)
                    .accessibilityAddTraits(.isHeader)

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }

            // Image container (parent controls height)
            GeometryReader { geo in
                let outerCorner: CGFloat = 18
                let innerPadding: CGFloat = 12
                let innerCorner: CGFloat = 16
                let imageCorner: CGFloat = 14

                ZStack {
                    RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                        .fill(Theme.surface2)
                        .overlay(
                            RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                        .accessibilityHidden(true)

                    if let uiImage = image {
                        ZStack {
                            RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: innerCorner, style: .continuous)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                                .accessibilityHidden(true)

                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width - innerPadding * 2,
                                       height: geo.size.height - innerPadding * 2)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: imageCorner, style: .continuous))
                                .overlay(
                                    LinearGradient(
                                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.08)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: imageCorner, style: .continuous))
                                )
                                .accessibilityHidden(true) // decorative; parent provides label/value
                        }
                        .padding(innerPadding)
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(Theme.tertiary)
                                .accessibilityHidden(true)

                            Text(emptyStateTitle)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Theme.text)

                            Text(emptyStateSubtitle)
                                .font(.subheadline)
                                .foregroundStyle(Theme.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 18)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(22)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: outerCorner, style: .continuous))
            }
            .frame(minHeight: 160)
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Theme.bgTop.opacity(0.95))
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Theme.surface)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        // The parent (caller) should set .accessibilityLabel and .accessibilityValue for context.
    }
}
