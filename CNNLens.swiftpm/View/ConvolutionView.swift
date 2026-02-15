//
//  ConvolutionView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
//
import SwiftUI

private enum Design {
    enum Colors {
        static let background = Color(red: 0.02, green: 0.05, blue: 0.12)
        static let stroke = Color.blue.opacity(0.2)
        static let title = Color.white
        static let subtitle = Color.gray
        static let barActive = Color(white: 0.2)
        static let featureLabel = Color.blue
        static let infoFill = Color.blue.opacity(0.1)
        static let placeholder = Color.white.opacity(0.05)
    }
    enum Metrics {
        static let vStackSpacing: CGFloat = 24
        static let headerTopPadding: CGFloat = 20
        static let hStackSpacing: CGFloat = 20
        static let columnWidth: CGFloat = 280
        static let featureSize: CGFloat = 320
        static let kernelFieldWidth: CGFloat = 65
        static let kernelCorner: CGFloat = 20
        static let featureCorner: CGFloat = 24
        static let infoCorner: CGFloat = 20
        static let imageCorner: CGFloat = 15
        static let toggleCorner: CGFloat = 10
        static let navMinWidth: CGFloat = 88
        static let navMinHeight: CGFloat = 44
        static let backgroundOpacity: CGFloat = 0.2
    }
}

struct ConvolutionView: View {
    @StateObject var viewModel: ConvolutionViewModel
    
    var body: some View {
        ZStack {
            // Brand background
            Design.Colors.background.ignoresSafeArea()
            BackgroundNetworkView().opacity(Design.Metrics.backgroundOpacity)
            
            VStack(spacing: Design.Metrics.vStackSpacing) {
                StepProgressHeader(currentStep: "Convolution")
                    .padding(.top, Design.Metrics.headerTopPadding)
                
                Text("Convolution Playground")
                    .font(.title.bold())
                    .foregroundColor(Design.Colors.title)
                
                HStack(alignment: .top, spacing: Design.Metrics.hStackSpacing) {
                    kernelColumn
                        .frame(width: Design.Metrics.columnWidth)
                    
                    featureMapColumn
                    
                    explanationColumn
                        .frame(width: Design.Metrics.columnWidth)
                }
                
                Spacer()
                
                navigationBar
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Sections (preserve exact visuals)
    
    private var kernelColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("3×3 Kernel")
                .font(.headline)
                .foregroundColor(Design.Colors.title)
            
            HStack {
                ForEach(["Edge", "Blur", "Sharpen", "Emboss"], id: \.self) { p in
                    Button(p) {
                        viewModel.selectedPreset = p
                        viewModel.kernel = KernelPresets.all.first(where: { $0.name == p })?.matrix ?? viewModel.kernel
                        viewModel.process()
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.selectedPreset == p ? .blue : .gray)
                    .accessibilityLabel("\(p) preset")
                }
            }
            
            VStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { r in
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { c in
                            TextField("", value: $viewModel.kernel[r][c], format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: Design.Metrics.kernelFieldWidth)
                                .multilineTextAlignment(.center)
                                .onChange(of: viewModel.kernel[r][c]) { _ in viewModel.process() }
                                .accessibilityLabel("Kernel value row \(r + 1), column \(c + 1)")
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Stride: \(viewModel.stride)").font(.caption).foregroundColor(.blue)
                Slider(value: .constant(1), in: 1...2)
                    .accessibilityLabel("Stride")
                Text("Padding: \(viewModel.padding)").font(.caption).foregroundColor(.blue)
                Slider(value: .constant(0), in: 0...1)
                    .accessibilityLabel("Padding")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: Design.Metrics.kernelCorner, style: .continuous)
                .stroke(Design.Colors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.kernelCorner, style: .continuous))
    }
    
    private var featureMapColumn: some View {
        VStack(spacing: 12) {
            Text("Feature Map")
                .font(.caption.smallCaps())
                .foregroundColor(Design.Colors.featureLabel)
            
            if let img = viewModel.featureMap {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Design.Metrics.featureSize, height: Design.Metrics.featureSize)
                    .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.imageCorner, style: .continuous))
                    .accessibilityLabel("Feature map image")
            } else {
                RoundedRectangle(cornerRadius: Design.Metrics.imageCorner, style: .continuous)
                    .fill(Design.Colors.placeholder)
                    .frame(width: Design.Metrics.featureSize, height: Design.Metrics.featureSize)
                    .overlay(Text("No output yet").foregroundColor(.gray))
                    .accessibilityHidden(true)
            }
            
            HStack(spacing: 0) {
                Button("None") { viewModel.isReLUActive = false; viewModel.process() }
                    .frame(minHeight: 44)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(!viewModel.isReLUActive ? Design.Colors.barActive : Color.clear)
                    .accessibilityLabel("No activation")
                Button("ReLU") { viewModel.isReLUActive = true; viewModel.process() }
                    .frame(minHeight: 44)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(viewModel.isReLUActive ? Design.Colors.barActive : Color.clear)
                    .accessibilityLabel("ReLU activation")
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.toggleCorner, style: .continuous))
            .foregroundColor(.white)
        }
        .padding()
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: Design.Metrics.featureCorner, style: .continuous)
                .stroke(Design.Colors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.featureCorner, style: .continuous))
    }
    
    private var explanationColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What does this detect?")
                .font(.headline)
                .foregroundColor(Design.Colors.title)
            Text(viewModel.currentDescription)
                .font(.subheadline)
                .foregroundColor(Design.Colors.subtitle)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("AI Insight", systemImage: "lightbulb.fill")
                    .font(.caption.bold())
                    .foregroundColor(Design.Colors.title)
                Text("In a real CNN, these kernel values are learned during training, not set by humans.")
                    .font(.caption)
                    .foregroundColor(Design.Colors.subtitle)
            }
            .padding()
            .background(Design.Colors.infoFill)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding()
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: Design.Metrics.infoCorner, style: .continuous)
                .stroke(Design.Colors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Design.Metrics.infoCorner, style: .continuous))
    }
    
    private var navigationBar: some View {
        HStack {
            Button("Back") {}
                .buttonStyle(.bordered)
                .tint(.gray)
                .frame(minWidth: Design.Metrics.navMinWidth, minHeight: Design.Metrics.navMinHeight)
            Spacer()
            Button("Next") {}
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .frame(minWidth: Design.Metrics.navMinWidth, minHeight: Design.Metrics.navMinHeight)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}
