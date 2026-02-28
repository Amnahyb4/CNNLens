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

    var body: some View {
        ZStack {
            background
                .accessibilityHidden(vm.showCompletionPrompt) // hide when modal is up

            GeometryReader { proxy in
                let sideWidth = clampedSideWidth(for: proxy.size.width)

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
                        ChallengeInfoCard(
                            title: "Challenge Goal",
                            conceptTitle: vm.challenge.title,
                            goal: vm.challenge.goal,
                            hints: vm.challenge.hints,
                            criteria: vm.challenge.criteria,
                            statusText: vm.evaluation.statusText,
                            educationalText: vm.challenge.educationalText
                        )
                        .frame(width: sideWidth, alignment: .top)
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
            
            // SUCCESS POPUP: Triggered upon 100% completion
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
            // Semi-transparent backdrop to focus attention
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { vm.showCompletionPrompt = false }
                .accessibilityHidden(true)

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    // Uses dynamic phrase from VM (e.g., "Outstanding" or "Excellent Thinker!!")
                    Text(vm.completionPhrase.isEmpty ? "Great Job!" : vm.completionPhrase)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Text("You've mastered \(vm.challenge.title)! Ready to explore a different concept?")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                VStack(spacing: 12) {
                    // Primary Navigation Button
                    Button {
                        vm.showCompletionPrompt = false
                        dismiss() // Return to Challenge Selection
                    } label: {
                        Text("Choose Another Challenge")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accent) // Uses your theme's primary color
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // Secondary Stay Button (HIG compliance)
                    Button {
                        vm.showCompletionPrompt = false
                    } label: {
                        Text("Stay Here")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(28)
            .frame(width: 360)
            .background(.ultraThinMaterial) // Signature Apple glass effect
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
            // Dynamically show "- Challenge Name - Playground"
            Text("\(vm.challenge.title) Playground")
                .font(.title2.weight(.bold))
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
        .background(Theme.surface)
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
