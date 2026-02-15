//
//  PreprocessingView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 25/08/1447 AH.
//
import SwiftUI

struct PreprocessingView: View {
    @StateObject private var viewModel: PreprocessingViewModel
    @Environment(\.dismiss) var dismiss
    @State private var goToConvolution = false
    
    init(imageName: String) {
        _viewModel = StateObject(wrappedValue: PreprocessingViewModel(selectedImageName: imageName))
    }
    
    // A soft bluish translucent surface that blends with the brand background (no gray cast)
    private var cardFill: Color {
        Color.blue.opacity(0.06)
    }
    
    var body: some View {
        ZStack {
            // Match SampleSelectionView background (brand background)
            Color(red: 0.02, green: 0.05, blue: 0.12).ignoresSafeArea()
            BackgroundNetworkView().opacity(0.25)
            
            VStack(spacing: 28) {
                StepProgressHeader(currentStep: "Input")
                    .padding(.top, 20)
                
                Text("Preprocessing")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Before a CNN processes an image, it must be prepared.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                // Comparison Section
                HStack(spacing: 24) {
                    ImageCard(title: "Original",
                              image: UIImage(named: viewModel.originalImageName),
                              accent: .gray,
                              fill: cardFill)
                    ImageCard(title: "Processed",
                              image: viewModel.processedImage,
                              accent: .blue,
                              fill: cardFill)
                }
                .accessibilityElement(children: .contain)
                
                // Controls Card (now uses the same tinted fill)
                VStack(spacing: 0) {
                    ToggleRow(label: "Resize to 224 × 224", sub: "Standard CNN dimensions", isOn: $viewModel.state.isResized)
                    Divider().background(Color.blue.opacity(0.14))
                    ToggleRow(label: "Normalize Pixels", sub: "Scale values to 0–1 range", isOn: $viewModel.state.isNormalized)
                    Divider().background(Color.blue.opacity(0.14))
                    ToggleRow(label: "Grayscale", sub: "Convert to single channel", isOn: $viewModel.state.isGrayscale)
                }
                .background(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.blue.opacity(0.22), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .frame(maxWidth: 560)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
                .accessibilityElement(children: .contain)
                
                Spacer(minLength: 0)
                
                // Navigation (HIG: standard styles, adequate targets)
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .frame(minWidth: 88, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .tint(.gray)
                    
                    Spacer()
                    
                    Button {
                        goToConvolution = true
                    } label: {
                        Text("Next")
                            .frame(minWidth: 88, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .foregroundColor(.white)
                
                // Hidden NavigationLink that triggers when Next is tapped
                NavigationLink(isActive: $goToConvolution) {
                    Group {
                        if let img = UIImage(named: viewModel.originalImageName) {
                            ConvolutionView(viewModel: ConvolutionViewModel(image: img))
                        } else {
                            Text("Unable to load image").foregroundColor(.red)
                        }
                    }
                } label: {
                    EmptyView()
                }
                .hidden()
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
    }
}

private struct ImageCard: View {
    let title: String
    let image: UIImage?
    var accent: Color
    var fill: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption.smallCaps())
                .foregroundColor(accent)
            
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityLabel("\(title) image")
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .accessibilityHidden(true)
            }
        }
        .padding(16)
        .background(fill)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.blue.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
    }
}

struct ToggleRow: View {
    let label: String
    let sub: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .foregroundColor(.white)
                Text(sub)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer(minLength: 16)
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label). \(sub)")
        .accessibilityValue(isOn ? "On" : "Off")
    }
}
