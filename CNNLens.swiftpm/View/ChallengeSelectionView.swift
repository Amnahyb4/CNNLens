//
//  ChallengeSelectionView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 02/09/1447 AH.
import SwiftUI

struct ChallengeSelectionView: View {

    let selectedSample: SampleImage?

    @StateObject private var vm = ChallengeSelectionViewModel()

    @State private var navigateToPlayground: Bool = false

    // Keep onContinue if you still want an external callback
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

            NavigationLink(
                destination: makePlaygroundDestination(),
                isActive: $navigateToPlayground
            ) {
                EmptyView()
            }
            .hidden()
        }
        // Show the default navigation bar so the system back button appears
        .navigationTitle("Choose a Challenge")
        .navigationBarTitleDisplayMode(.inline)
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
                .font(.system(size: 44, weight: .bold))
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

            Button {
                guard let selected = vm.selected else { return }

                // Optional callback
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
        }
        .background(Color.black.opacity(0.0001))
    }
}
