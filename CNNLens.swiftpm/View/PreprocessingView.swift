//
//  PreprocessingView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 25/08/1447 AH.
//
import SwiftUI

private enum Design {
    enum Colors {
        static let background = Color(red: 0.02, green: 0.05, blue: 0.12)
        static let cardFill = Color.blue.opacity(0.06)
        static let stroke = Color.blue.opacity(0.22)
        static let divider = Color.blue.opacity(0.14)
        static let title = Color.white
        static let subtitle = Color.gray
        static let navTint = Color.blue
        static let navSecondary = Color.gray
        static let placeholder = Color.white.opacity(0.05)
    }
    enum Metrics {
        static let vStackSpacing: CGFloat = 28
        static let sectionSpacing: CGFloat = 24
        static let titleTopPadding: CGFloat = 20
        static let cardCorner: CGFloat = 20
        static let innerCorner: CGFloat = 16
        static let imageCorner: CGFloat = 12
        static let imageSize: CGFloat = 300
        static let controlsMaxWidth: CGFloat = 560
        static let rowPadding: CGFloat = 12
        static let cardPadding: CGFloat = 16
        static let shadowRadius: CGFloat = 8
        static let shadowX: CGFloat = 0
        static let shadowY: CGFloat = 6
        static let bottomPadding: CGFloat = 8
        static let backgroundOpacity: CGFloat = 0.25
    }
}

struct PreprocessingView: View {
    @StateObject private var viewModel: PreprocessingViewModel
    @Environment(\.dismiss) var dismiss
    @State private var goToConvolution = false
    
    init(imageName: String) {
        _viewModel = StateObject(wrappedValue: PreprocessingViewModel(selectedImageName: imageName))
    }
    
    var body: some View {
        ZStack {
            // Brand background
            Design.Colors.background.ignoresSafeArea()
            BackgroundNetworkView().opacity(Design.Metrics.backgroundOpacity)
            
            VStack(spacing: Design.Metrics.vStackSpacing) {
                StepProgressHeader(currentStep: "Input")
                    .padding(.top, Design.Metrics.titleTopPadding)
                
                Text("Preprocessing")
                    .font(.title.bold())
                    .foregroundColor(Design.Colors.title)
                
                Text("Before a CNN processes an image, it must be prepared.")
                    .font(.body)
                    .foregroundColor(Design.Colors.subtitle)
                    .multilineTextAlignment(.center)
                
                // Comparison Section
                HStack(spacing: Design.Metrics.sectionSpacing) {
                    ImageCard(title: "Original",
                              image: UIImage(named: viewModel.originalImageName),
                              accent: .gray,
                              fill: Design.Colors.cardFill)
                    ImageCard(title: "Processed",
                              image: viewModel.processedImage,
                              accent: .blue,
                              fill: Design.Colors.cardFill)
                }
                .accessibilityElement(children: .contain)
                
                // Controls Card
                controlsCard
                    .frame(maxWidth: Design.Metrics.controlsMaxWidth)
                    .shadow(color: .black.opacity(0.25), radius: Design.Metrics.shadowRadius, x: Design.Metrics.shadowX, y: Design.Metrics.shadowY)
                    .accessibilityElement(children: .contain)
                
                Spacer(minLength: 0)
                
                // Navigation
                navigationBar
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $goToConvolution) {
            if let img = UIImage(named: viewModel.originalImageName) {
                ConvolutionView(viewModel: ConvolutionViewModel(image: img))
            } else {
                Text("Unable to load image").foregroundColor(.red)
            }
        }
    }
    
    private var controlsCard: some View {
        VStack(spacing: 0) {
            ToggleRow(label: "Resize to 224 × 224", sub: "Standard CNN dimensions", isOn: $viewModel.state.isResized)
            Divider().background(Design.Colors.divider)
            ToggleRow(label: "Normalize Pixels", sub: "Scale values to 0–1 range", isOn: $viewModel.state.isNormalized)
            Divider().background(Design.Colors.divider)
            ToggleRow(label: "Grayscale", sub: "Convert to single channel", isOn: $viewModel.state.isGrayscale)
        }
        .background(Design.Colors.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: Design.Metrics.innerCorner, style: .continuous)
                .stroke(Design.Colors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.innerCorner, style: .continuous))
    }
    
    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .frame(minWidth: 88, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .tint(Design.Colors.navSecondary)
            
            Spacer()
            
            Button {
                goToConvolution = true
            } label: {
                Text("Next")
                    .frame(minWidth: 88, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(Design.Colors.navTint)
        }
        .padding(.horizontal)
        .padding(.bottom, Design.Metrics.bottomPadding)
        .foregroundColor(.white)
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
                    .frame(width: Design.Metrics.imageSize, height: Design.Metrics.imageSize)
                    .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.imageCorner, style: .continuous))
                    .accessibilityLabel("\(title) image")
            } else {
                RoundedRectangle(cornerRadius: Design.Metrics.imageCorner, style: .continuous)
                    .fill(Design.Colors.placeholder)
                    .frame(width: Design.Metrics.imageSize, height: Design.Metrics.imageSize)
                    .accessibilityHidden(true)
            }
        }
        .padding(Design.Metrics.cardPadding)
        .background(fill)
        .overlay(
            RoundedRectangle(cornerRadius: Design.Metrics.cardCorner, style: .continuous)
                .stroke(Design.Colors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.cardCorner, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: Design.Metrics.shadowRadius, x: Design.Metrics.shadowX, y: Design.Metrics.shadowY)
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
