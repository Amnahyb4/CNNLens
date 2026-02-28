import SwiftUI

struct ImagePreviewCard: View {
    let title: String
    let image: UIImage?
    let emptyStateTitle: String
    let emptyStateSubtitle: String

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header row: Marked as a header for logical navigation
            VStack(alignment: .leading, spacing: 10) {
                Text(title.uppercased())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.tertiary)
                    .tracking(0.7)
                    .accessibilityAddTraits(.isHeader)

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }

            // Image container
            GeometryReader { geo in
                let outerCorner: CGFloat = 18
                let innerPadding: CGFloat = 12
                let innerCorner: CGFloat = 16
                let imageCorner: CGFloat = 14

                ZStack {
                    RoundedRectangle(cornerRadius: outerCorner, style: .continuous)
                        .fill(reduceTransparency ? Theme.surface2Opaque : Theme.surface2Translucent)
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
                                .frame(
                                    width: geo.size.width - (innerPadding * 2),
                                    height: geo.size.height - (innerPadding * 2),
                                    alignment: .center
                                )
                                .clipped()
                                .accessibilityHidden(true) // Decorative; parent card describes state
                        }
                        .padding(innerPadding)
                        .clipShape(RoundedRectangle(cornerRadius: imageCorner, style: .continuous))
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
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(18)
        .background(reduceTransparency ? Theme.surfaceOpaque : Theme.surfaceTranslucent)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        // Accessibility Refinement: Combine into a single logical block
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
        // Added Value: Clearly states if the image is ready or missing
        .accessibilityValue(image == nil ? emptyStateTitle : "Image loaded and visible.")
    }
}
