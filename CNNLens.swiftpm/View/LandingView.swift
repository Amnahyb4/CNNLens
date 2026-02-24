//
//  LandingView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 23/08/1447 AH.
//
import SwiftUI

private enum Design {
    enum Colors {
        static let background = Color(red: 0.02, green: 0.05, blue: 0.12)
        static let titleGradient = [Color.blue.opacity(0.7), Color.purple.opacity(0.8)]
        static let description = Color.gray
        static let ctaTint = Color.blue
    }
    enum Metrics {
        static let titleSize: CGFloat = 69
        static let descriptionMaxWidth: CGFloat = 620
        static let buttonMaxWidth: CGFloat = 360
        static let buttonMinHeight: CGFloat = 44
        static let horizontalPadding: CGFloat = 24
        static let vStackSpacing: CGFloat = 28
        static let topPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 12
        static let backgroundOpacity: CGFloat = 0.4
    }
}

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    
    var body: some View {
        ZStack {
            // Brand background
            Design.Colors.background
                .ignoresSafeArea()
            
            BackgroundNetworkView()
                .opacity(Design.Metrics.backgroundOpacity)
                .allowsHitTesting(false)
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, Design.Metrics.horizontalPadding)
        }
    }
    
    private var content: some View {
        VStack(spacing: Design.Metrics.vStackSpacing) {
            // Main Title
            Text(viewModel.config.title)
                .font(.system(size: Design.Metrics.titleSize, weight: .bold))
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: Design.Colors.titleGradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .accessibilityAddTraits(.isHeader)
            
            // Description
            Text(viewModel.config.description)
                .font(.title3)
                .foregroundColor(Design.Colors.description)
                .multilineTextAlignment(.center)
                .frame(maxWidth: Design.Metrics.descriptionMaxWidth)
                .padding(.horizontal, Design.Metrics.horizontalPadding)
            
            // Primary Action Button
            Button(action: viewModel.startExperience) {
                Text(viewModel.config.buttonText)
                    .font(.headline)
                    .frame(maxWidth: Design.Metrics.buttonMaxWidth,
                           minHeight: Design.Metrics.buttonMinHeight)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(Design.Colors.ctaTint)
            .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.cornerRadius, style: .continuous))
            .padding(.top, Design.Metrics.topPadding)
            .accessibilityLabel(viewModel.config.buttonText)
            
            // Hidden NavigationLink that activates when startExperience() sets the flag
            NavigationLink(
                destination: SampleSelectionView(),
                isActive: $viewModel.navigateToSamples
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
}

// Preview for iPad/iPhone
struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LandingView()
                .preferredColorScheme(.dark)
                .dynamicTypeSize(...DynamicTypeSize.accessibility5)
        }
    }
}
