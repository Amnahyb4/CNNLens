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

    var body: some View {
        ZStack {
            background

            GeometryReader { proxy in
                let sideWidth = clampedSideWidth(for: proxy.size.width)

                VStack(spacing: 16) {

                    // Top Header (centered)
                    headerBar
                        .frame(maxWidth: PGLayout.maxContentWidth, alignment: .center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, PGLayout.outerHPadding)
                        .padding(.top, PGLayout.outerVPadding - 4)

                    // Main content columns
                    HStack(alignment: .top, spacing: PGLayout.gap) {

                        // LEFT
                        VStack(spacing: 16) {
                            CardContainer(title: "Kernel (3x3)", contentAlignment: .center) {
                                VStack(spacing: 14) {
                                    KernelGridView(kernel: $vm.kernel) { r, c, v in
                                        vm.updateKernel(row: r, col: c, value: v)
                                    }
                                }
                            }

                            MetricsListView(metrics: vm.metrics)
                        }
                        .frame(width: sideWidth, alignment: .top)

                        if PGLayout.showColumnDividers { columnDivider }

                        // CENTER
                        VStack(spacing: 16) {
                            ImagePreviewCard(
                                title: "ORIGINAL IMAGE",
                                image: vm.originalUIImage,
                                emptyStateTitle: "No image",
                                emptyStateSubtitle: "Select a sample image to continue."
                            )
                            .frame(height: PGLayout.imageCardHeight)
                            .accessibilityIdentifier("originalImageCard")

                            ImagePreviewCard(
                                title: "YOUR OUTPUT",
                                image: vm.outputUIImage,
                                emptyStateTitle: "No output yet",
                                emptyStateSubtitle: "Edit the kernel to generate output."
                            )
                            .frame(height: PGLayout.imageCardHeight)
                            .accessibilityIdentifier("outputImageCard")

                            ProgressBarView(label: "SIMILARITY", percent: vm.evaluation.similarityPercent)
                                .frame(height: PGLayout.progressHeight)
                                .accessibilityIdentifier("similarityCard")
                        }
                        .frame(maxWidth: .infinity, alignment: .top)

                        if PGLayout.showColumnDividers { columnDivider }

                        // RIGHT
                        ChallengeInfoCard(
                            title: "Challenge Goal",                 // Card header stays constant
                            conceptTitle: vm.challenge.title,        // Info popover/sheet shows selected challenge name
                            goal: vm.challenge.goal,
                            hints: vm.challenge.hints,
                            criteria: vm.challenge.criteria,
                            statusText: vm.evaluation.statusText,
                            educationalText: vm.challenge.educationalText
                        )
                        .frame(width: sideWidth, alignment: .top)
                        .accessibilityIdentifier("challengeInfoCard")
                    }
                    .frame(maxWidth: PGLayout.maxContentWidth, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, PGLayout.outerHPadding)
                    .padding(.bottom, PGLayout.outerVPadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        // HIG: present the preprocessing step as a sheet, not a custom overlay
        .sheet(isPresented: $vm.showPreprocessGate) {
            PreprocessGateView(options: $vm.preprocess) {
                vm.confirmPreprocessAndEnterLab()
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("PixelLab")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity, alignment: .center)

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Helpers

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

    // Clearer column divider: slightly higher opacity with a soft inner highlight
    private var columnDivider: some View {
        ZStack {
            Rectangle()
                .fill(Color.white.opacity(0.12)) // clearer than 0.06
            Rectangle()
                .fill(Color.white.opacity(0.22)) // subtle inner highlight
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

// MARK: - Shared Card Container + Header (unified styling)

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

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
        }
    }
}
