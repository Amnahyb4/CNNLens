import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 69
    
    private func responsiveHPadding(for width: CGFloat) -> CGFloat {
        if width >= 1100 { return 24 }
        if width >= 900  { return 20 }
        return 16
    }
    
    private func responsiveDescriptionWidth(for width: CGFloat) -> CGFloat {
        if width >= 1100 { return 620 }
        if width >= 900  { return 560 }
        return min(520, width - 48)
    }
    
    private func responsiveButtonWidth(for width: CGFloat) -> CGFloat {
        return min(360, width - 48)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.bgTop, Theme.bgBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            BackgroundNetworkView()
                .opacity(0.4)
                .allowsHitTesting(false)
                .accessibilityHidden(true) // Explicitly hide decorative background from VoiceOver
            
            GeometryReader { proxy in
                let w = proxy.size.width
                let hPad = responsiveHPadding(for: w)
                let descW = responsiveDescriptionWidth(for: w)
                let btnW = responsiveButtonWidth(for: w)
                
                content(descMaxWidth: descW, buttonWidth: btnW)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.horizontal, hPad)
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToSamples) {
            SampleSelectionView()
        }
    }
    
    private func content(descMaxWidth: CGFloat, buttonWidth: CGFloat) -> some View {
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
                .frame(maxWidth: descMaxWidth)
                .padding(.horizontal, 24)
            
            // Primary Action Button
            Button(action: viewModel.startExperience) {
                Text(viewModel.config.buttonText)
                    .font(.headline)
                    .frame(maxWidth: buttonWidth, minHeight: 50) // Increased to 50 for even better accessibility
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
