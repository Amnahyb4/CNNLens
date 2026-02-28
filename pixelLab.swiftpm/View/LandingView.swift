import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    
    // Use ScaledMetric so the 69pt title respects the user's text size settings
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 69
    
    var body: some View {
        ZStack {
            // Use your consistent brand background
            LinearGradient(colors: [Theme.bgTop, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            BackgroundNetworkView()
                .opacity(0.4)
                .allowsHitTesting(false)
                .accessibilityHidden(true) // Explicitly hide decorative background from VoiceOver
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 24)
        }
        .navigationDestination(isPresented: $viewModel.navigateToSamples) {
            SampleSelectionView()
        }
    }
    
    private var content: some View {
        VStack(spacing: 28) {
            // Main Title
            Text(viewModel.config.title)
                .font(.system(size: titleSize, weight: .bold)) // Now scales dynamically
                .minimumScaleFactor(0.7) // More generous scaling for accessibility
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .accessibilityAddTraits(.isHeader) // Correctly implemented
            
            // Description
            Text(viewModel.config.description)
                .font(.title3)
                .foregroundColor(Theme.secondary) // Improved contrast vs Color.gray
                .multilineTextAlignment(.center)
                .frame(maxWidth: 620)
                .padding(.horizontal, 24)
            
            // Primary Action Button
            Button(action: viewModel.startExperience) {
                Text(viewModel.config.buttonText)
                    .font(.headline)
                    .frame(maxWidth: 360, minHeight: 50) // Increased to 50 for even better accessibility
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.top, 8)
            .accessibilityLabel(viewModel.config.buttonText)
            .accessibilityHint("Starts the PixelLab experience.") // Added context for VoiceOver users
        }
    }
}
