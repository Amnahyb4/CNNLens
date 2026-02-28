import SwiftUI

private enum PGLayout {
    // Tuned for iPad tool UI
    static let baseSideWidth: CGFloat = 360
    static let minSideWidth: CGFloat = 320
    static let maxSideWidth: CGFloat = 380

    static let gap: CGFloat = 22
    static let outerHPadding: CGFloat = 28
    static let outerVPadding: CGFloat = 22
    static let maxContentWidth: CGFloat = 1360

    // Center column: wide image strips
    static let imageCardHeight: CGFloat = 340
    static let progressHeight: CGFloat = 72

    static let showColumnDividers: Bool = true
}

struct PlaygroundView: View {
    @StateObject var vm: PlaygroundViewModel
    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    // Dynamic Type-friendly large title with @ScaledMetric
    @ScaledMetric(relativeTo: .largeTitle) private var headerTitleSize: CGFloat = 24

    var body: some View {
        ZStack {
            background
                .accessibilityHidden(vm.showCompletionPrompt)

            GeometryReader { proxy in
                let sideWidth = clampedSideWidth(for: proxy.size.width)
                // Match right card height to center column (2 images + similarity + two spacings of 16)
                let centerColumnHeight = PGLayout.imageCardHeight * 2 + PGLayout.progressHeight + 2 * 16.0

                VStack(spacing: 16) {

                    // Top Header (Dynamic Challenge Name)
                    headerBar
                        .frame(maxWidth: PGLayout.maxContentWidth, alignment: .center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, PGLayout.outerHPadding)
                        .padding(.top, PGLayout.outerVPadding - 4)
                        .accessibilityHidden(vm.showCompletionPrompt)

                    // Main content columns
                    HStack(alignment: .top, spacing: PGLayout.gap) {

                        // LEFT: Controls & Metrics
                        VStack(spacing: 16) {
                            CardContainer(title: "Kernel (3x3)", contentAlignment: .center) {
                                VStack(spacing: 14) {
                                    KernelGridView(kernel: $vm.kernel) { r, c, v in
                                        vm.updateKernel(row: r, col: c, value: v)
                                    }
                                }
                            }
                            .accessibilityLabel("Kernel editor, 3 by 3 grid")

                            MetricsListView(metrics: vm.metrics)
                                .accessibilityLabel("Live metrics")
                        }
                        .frame(width: sideWidth, alignment: .top)
                        .accessibilityHidden(vm.showCompletionPrompt)

                        if PGLayout.showColumnDividers { columnDivider }

                        // CENTER: Image Previews
                        VStack(spacing: 16) {
                            ImagePreviewCard(
                                title: "ORIGINAL IMAGE",
                                image: vm.originalUIImage,
                                emptyStateTitle: "No image",
                                emptyStateSubtitle: "Select a sample image to continue."
                            )
                            .frame(height: PGLayout.imageCardHeight)
                            .accessibilityIdentifier("originalImageCard")
                            .accessibilityLabel("Original image")
                            .accessibilityValue(vm.originalUIImage == nil ? "No image selected" : "Image loaded")

                            ImagePreviewCard(
                                title: "YOUR OUTPUT",
                                image: vm.outputUIImage,
                                emptyStateTitle: "No output yet",
                                emptyStateSubtitle: "Edit the kernel to generate output."
                            )
                            .frame(height: PGLayout.imageCardHeight)
                            .accessibilityIdentifier("outputImageCard")
                            .accessibilityLabel("Your output image")
                            .accessibilityValue(vm.outputUIImage == nil ? "No output yet" : "Output generated")

                            ProgressBarView(label: "SIMILARITY", percent: vm.evaluation.similarityPercent)
                                .frame(height: PGLayout.progressHeight)
                                .accessibilityIdentifier("similarityCard")
                                .accessibilityLabel("Similarity")
                                .accessibilityValue(vm.evaluation.similarityPercent == nil ? "No value" : String(format: "%.1f percent", vm.evaluation.similarityPercent!))
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                        .accessibilityHidden(vm.showCompletionPrompt)

                        if PGLayout.showColumnDividers { columnDivider }

                        // RIGHT: Goal & Education
                        VStack { // Wrap in a VStack to use a Spacer
                            ChallengeInfoCard(
                                title: "Challenge Goal",
                                conceptTitle: vm.challenge.title,
                                goal: vm.challenge.goal,
                                hints: vm.challenge.hints,
                                criteria: vm.challenge.criteria,
                                statusText: vm.evaluation.statusText,
                                educationalText: vm.challenge.educationalText,
                                minHeight: centerColumnHeight
                            )
                            .frame(width: sideWidth) // Let the card take its natural height up to centerColumnHeight
                            .frame(height: centerColumnHeight, alignment: .top) // Force the container to match the center column exactly
                            
                            Spacer(minLength: 0) // Ensures that if the card is somehow smaller, it stays pinned to the top line
                        }
                        .frame(width: sideWidth, height: centerColumnHeight) // Final containment to match the center column's bottom edge
                        .accessibilityIdentifier("challengeInfoCard")
                        .accessibilityHidden(vm.showCompletionPrompt)
                    }
                    .frame(maxWidth: PGLayout.maxContentWidth, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, PGLayout.outerHPadding)
                    .padding(.bottom, PGLayout.outerVPadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            
            // SUCCESS POPUP
            if vm.showCompletionPrompt {
                successOverlay
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(10)
                    .accessibilityAddTraits(.isModal)
            }
        }
        .animation(reduceMotion ? .default : .spring(response: 0.4, dampingFraction: 0.75), value: vm.showCompletionPrompt)
        .sheet(isPresented: $vm.showPreprocessGate) {
            PreprocessGateView(options: $vm.preprocess) {
                vm.confirmPreprocessAndEnterLab()
            }
        }
    }

    // MARK: - Success Popup UI

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { vm.showCompletionPrompt = false }
                .accessibilityHidden(true)

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(vm.completionPhrase.isEmpty ? "Great Job!" : vm.completionPhrase)
                        .font(.title) // Dynamic Type-friendly
                        .foregroundStyle(.white)
                    
                    Text("You've mastered \(vm.challenge.title)! Ready to explore a different concept?")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 12) {
                    Button {
                        vm.showCompletionPrompt = false
                        dismiss()
                    } label: {
                        Text("Choose Another Challenge")
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        vm.showCompletionPrompt = false
                    } label: {
                        Text("Stay Here")
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(28)
            .frame(width: 360)
            .background {
                if reduceTransparency {
                    Theme.surfaceOpaque
                } else {
                    Rectangle().fill(.ultraThinMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 30, y: 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Challenge completed")
            .accessibilityHint("Choose another challenge or stay here.")
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("\(vm.challenge.title) Playground")
                .font(.system(size: headerTitleSize, weight: .bold, design: .default)) // Scales with Dynamic Type via @ScaledMetric
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .center)

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vm.challenge.title) Playground")
    }

    // MARK: - Layout Helpers

    private func clampedSideWidth(for totalWidth: CGFloat) -> CGFloat {
        let proposed = PGLayout.baseSideWidth
        if totalWidth < 1000 {
            return max(PGLayout.minSideWidth, proposed - 20)
        } else if totalWidth > 1400 {
            return min(PGLayout.maxSideWidth, proposed + 10)
        } else {
            return proposed
        }
    }

    private var columnDivider: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.12))
            Rectangle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 1)
                .opacity(0.35)
        }
        .frame(width: 1)
        .padding(.top, 10)
        .accessibilityHidden(true)
    }

    private var background: some View {
        LinearGradient(colors: [Theme.bgTop, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

// MARK: - Card Infrastructure

private struct CardContainer<Content: View>: View {
    let title: String
    let contentAlignment: Alignment
    @ViewBuilder var content: Content

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    init(title: String, contentAlignment: Alignment = .leading, @ViewBuilder content: () -> Content) {
        self.title = title
        self.contentAlignment = contentAlignment
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardHeader(title: title)
            content
                .frame(maxWidth: .infinity, alignment: contentAlignment)
                .padding(.top, 2)
        }
        .padding(18)
        .background(reduceTransparency ? Theme.surfaceOpaque : Theme.surfaceTranslucent)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}

private struct CardHeader: View {
    let title: String
    var body: some View {
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
    }
}
