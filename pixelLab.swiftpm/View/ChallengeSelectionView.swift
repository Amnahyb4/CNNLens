
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
                    .accessibilityLabel("\(c.title)")
                    .accessibilityValue(vm.selected == c ? "Selected" : "Not selected")
                    .accessibilityHint("Double tap to select this challenge.")
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

                // Navigate to Playground
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
            .accessibilityHint(vm.canContinue ? "Opens the lab for the selected challenge." : "Select a challenge to continue.")
            .keyboardShortcut(.defaultAction) // Return/Enter triggers primary action
        }
        .background(Color.black.opacity(0.0001))
    }
}
