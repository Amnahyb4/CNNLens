//
//  LandingView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 23/08/1447 AH.
//
import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = LandingViewModel()
    
    var body: some View {
        ZStack {
            // Brand background
            Color(red: 0.02, green: 0.05, blue: 0.12)
                .ignoresSafeArea()
            
            BackgroundNetworkView()
                .opacity(0.4)
                .allowsHitTesting(false)
            
            VStack(spacing: 28) {
                // Main Title (larger, still Dynamic Type friendly)
                Text(viewModel.config.title)
                    .font(.system(size: 44, weight: .bold)) // bigger than largeTitle on iPad look
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.7), .purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .accessibilityAddTraits(.isHeader)
                
                // Description (larger than body for improved readability)
                Text(viewModel.config.description)
                    .font(.title3) // was .body
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 620)
                    .padding(.horizontal, 24)
                
                // Primary Action Button (smaller footprint)
                Button(action: {
                    viewModel.startExperience()
                }) {
                    Text(viewModel.config.buttonText)
                        .font(.headline) // readable but not oversized
                        .frame(maxWidth: 360, minHeight: 44) // slimmer button
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small) // tighter padding than .regular/.large
                .tint(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.top, 8)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, 24)
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
