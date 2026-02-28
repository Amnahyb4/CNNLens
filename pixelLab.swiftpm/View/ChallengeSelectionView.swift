import SwiftUI

struct ChallengeSelectionView: View {

    let selectedSample: SampleImage?

    @StateObject private var vm = ChallengeSelectionViewModel()

    @State private var navigateToPlayground: Bool = false

    var onContinue: ((Challenge) -> Void)? = nil

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                ScrollView {
                    content
                        .padding(.horizontal, 48)
                        .padding(.top, 24)
                        .padding(.bottom, 120)
                }

                bottomCTA
            }
        }
        // UI Fix: We set this to empty to remove the redundant top title
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // UI Fix: These modifiers make the nav bar transparent so the gradient is full-screen
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToPlayground) {
            makePlaygroundDestination()
        }
    }

    // MARK: - Destination builder
    @ViewBuilder
    private func makePlaygroundDestination() -> some View {
        if let sample = selectedSample, let challenge = vm.selected {
            PlaygroundView(
                vm: PlaygroundViewModel(
                    challenge: challenge,
                    originalAssetName: sample.imageName
                )
            )
        } else {
            Text("Missing selection")
                .foregroundStyle(.white)
        }
    }

    private var background: some View {
        LinearGradient(colors: [Theme.bgTop, Theme.bgBottom],
                       startPoint: .top,
                       endPoint: .bottom)
        .ignoresSafeArea()
    }

    private var content: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("Choose a Challenge")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.text)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityAddTraits(.isHeader)

            Text("Select a spatial filtering concept to explore.")
                .font(.title3)
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: 18) {
                ForEach(vm.challenges) { c in
                    ChallengeRowCard(
                        challenge: c,
                        isSelected: vm.selected == c,
                        onTap: { vm.select(c) }
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(c.title) challenge")
                    .accessibilityValue(vm.selected == c ? "Selected" : "")
                    .accessibilityAddTraits(vm.selected == c ? [.isButton, .isSelected] : [.isButton])
                    .accessibilityHint("Selects the \(c.title) concept.")
                }
            }
            .padding(.top, 18)
        }
        .frame(maxWidth: 980)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
                .accessibilityHidden(true)

            Button {
                guard let selected = vm.selected else { return }

                onContinue?(selected)

                navigateToPlayground = true
            } label: {
                Label("Continue to Lab", systemImage: "arrow.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .tint(Theme.accent)
            .disabled(!vm.canContinue)
            .opacity(vm.canContinue ? 1 : 0.6)
            .padding(EdgeInsets(top: 12, leading: 48, bottom: 16, trailing: 48))
            .accessibilityHint(vm.canContinue ? "Opens the lab for the selected challenge." : "Select a challenge above to enable this button.")
            .keyboardShortcut(.defaultAction)
        }
        .background(Color.black.opacity(0.0001))
    }
}
