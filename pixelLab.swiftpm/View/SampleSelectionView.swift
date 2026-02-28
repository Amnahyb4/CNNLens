import SwiftUI

struct SampleSelectionView: View {
    @StateObject private var viewModel = SampleSelectionViewModel()
    
    private func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        if width >= 700 {
            return [GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)]
        } else {
            // Narrow / split view: 1 column so cards don't get squished
            return [GridItem(.flexible(), spacing: 20)]
        }
    }
    
    private func responsiveHPadding(for width: CGFloat) -> CGFloat {
        if width >= 900 { return 40 }
        if width >= 700 { return 28 }
        return 16
    }
    
    private func responsiveMaxGridWidth(for width: CGFloat) -> CGFloat {
        if width >= 900 { return 840 }
        if width >= 700 { return min(760, width - 56) } // slightly smaller
        return width - 32                               // narrow
    }
    
    var body: some View {
        ZStack {
            Theme.bgTop.ignoresSafeArea()
            
            BackgroundNetworkView()
                .opacity(0.15)
                .accessibilityHidden(true)
            
            GeometryReader { proxy in
                let w = proxy.size.width
                let cols = adaptiveColumns(for: w)
                let hPad = responsiveHPadding(for: w)
                let maxW = responsiveMaxGridWidth(for: w)
                
                VStack(spacing: 0) {
                    header
                        .padding(.top, 30)
                        .padding(.bottom, 24)

                    ScrollView {
                        LazyVGrid(columns: cols, spacing: 20) {
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
                        // ✅ UPDATED (ADD): padding now responsive
                        .padding(.horizontal, hPad)
                        .padding(.bottom, 40)
                        // ✅ UPDATED (ADD): max width responsive (keeps your 840 when possible)
                        .frame(maxWidth: maxW)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
