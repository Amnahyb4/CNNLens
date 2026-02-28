import SwiftUI

struct SampleSelectionView: View {
    @StateObject private var viewModel = SampleSelectionViewModel()
    
    // UI Fix: Use fixed columns to ensure it stays 2-across on iPad
    private var columns: [GridItem] {
        [GridItem(.flexible(), spacing: 20),
         GridItem(.flexible(), spacing: 20)]
    }
    
    var body: some View {
        ZStack {
            Theme.bgTop.ignoresSafeArea()
            
            BackgroundNetworkView()
                .opacity(0.15)
                .accessibilityHidden(true)
            
            VStack(spacing: 0) {
                header
                    .padding(.top, 30)
                    .padding(.bottom, 24)

                ScrollView {
                    // Grid constrained to 840 max width for better 2x2 spacing
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.samples) { sample in
                            Button {
                                viewModel.selectImage(sample)
                            } label: {
                                SampleCard(sample: sample)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Sample: \(sample.name)")
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    .frame(maxWidth: 840)
                }
                .frame(maxWidth: .infinity)
            }
        }
        // Maintains your premium immersive navigation
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $viewModel.navigateToChallenges) {
            ChallengeSelectionView(selectedSample: viewModel.selectedSample)
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Text("Choose a Sample")
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundColor(Theme.text)
            
            Text("Select an image to explore the mathematics of convolution.")
                .font(.subheadline)
                .foregroundColor(Theme.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Subviews
// This fixes the "Cannot find SampleCard in scope" error
private struct SampleCard: View {
    let sample: SampleImage
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // UI Fix: Forces a clean 4:3 ratio so cards are compact
            Color.clear
                .aspectRatio(4/3, contentMode: .fit)
                .overlay(
                    Image(sample.imageName)
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .accessibilityHidden(true)
            
            // Subtle dark overlay for text legibility
            LinearGradient(
                colors: [.black.opacity(0.6), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            Text(sample.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}
