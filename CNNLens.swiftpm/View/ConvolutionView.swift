import SwiftUI

struct ConvolutionView: View {
    @StateObject var viewModel: ConvolutionViewModel
    @State private var isLearnMoreExpanded: Bool = false
    
    // MARK: - Organized Design System Metrics
    private let sideCardWidth: CGFloat = 340
    private let centerCardWidth: CGFloat = 460
    private let cardHeight: CGFloat = 650 // Locked height for perfect alignment
    private let glassBackground = Color.white.opacity(0.06)
    private let glassStroke = Color.white.opacity(0.12)

    var body: some View {
        ZStack {
            // Ambient Dashboard Background
            Color(red: 0.02, green: 0.05, blue: 0.12).ignoresSafeArea()
            BackgroundNetworkView().opacity(0.12)
            
            VStack(spacing: 30) {
                // MARK: - Header
                VStack(spacing: 8) {
                    StepProgressHeader(currentStep: "Convolution")
                        .padding(.top, 10)
                    Text("Convolution Playground")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }

                // MARK: - 3-Column Dashboard Grid
                HStack(alignment: .top, spacing: 24) {
                    
                    // LEFT: Kernel Controls
                    dashboardCard(width: sideCardWidth) {
                        VStack(alignment: .leading, spacing: 24) {
                            CardHeader(title: "3x3 Kernel", icon: "square.grid.3x3")
                            presetSelector
                            kernelInputGrid // Numbers visible and bold
                            
                            Spacer()
                            parameterSection // Fixed visible numbers
                        }
                    }

                    // CENTER: Visual Feature Map Hero
                    dashboardCard(width: centerCardWidth) {
                        VStack(spacing: 24) {
                            Text("FEATURE MAP")
                                .font(.system(size: 20, weight: .black))
                                .kerning(4)
                                .foregroundColor(.blue)

                            mainFeatureDisplay
                            
                            Text("Output size varies with stride & padding")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer()
                            activationToggleRow // Standard Toggle design
                        }
                    }

                    // RIGHT: The Refined Analysis Card
                    dashboardCard(width: sideCardWidth) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("What does this detect?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            // High-Visibility Description
                            Text(viewModel.currentDescription)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                            
                            // Purple-Tinted AI Insight Box
                            aiInsightBox
                            
                            // Learn More Disclosure
                            learnMoreAccordion
                            
                            Spacer() // Alignment anchor
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
                navigationFooter
            }
        }
    }

    // MARK: - UI Subcomponents

    private var aiInsightBox: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                (Text("In a real CNN, the network ") + Text("learns").bold() + Text(" these kernel values during training — hundreds of them — each specializing in different patterns."))
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .lineSpacing(3)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.15)) // Reverted to purple design
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple.opacity(0.2), lineWidth: 1))
    }

    private var learnMoreAccordion: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring()) { isLearnMoreExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isLearnMoreExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                    Text("Learn More")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.blue)
            }
            
            if isLearnMoreExpanded {
                Text("Convolution is the core operation of CNNs. The kernel slides across the input image. At each position, element-wise multiplication and summation produce a single output value. Stride controls kernel movement, while padding adds a border to preserve dimensions.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(5)
                    .padding()
                    .background(Color.black.opacity(0.3)) // Dark inset box
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var kernelInputGrid: some View {
        let cols = Array(repeating: GridItem(.fixed(85), spacing: 12), count: 3)
        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(0..<3) { r in
                ForEach(0..<3) { c in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.4))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(glassStroke))
                        
                        TextField("", value: $viewModel.kernel[r][c], format: .number)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .keyboardType(.numbersAndPunctuation) // Optimization for iPad input
                            
                            // TRIGGERS: This makes the Feature Map change as you type
                            .onChange(of: viewModel.kernel[r][c]) { _ in
                                viewModel.process()
                            }
                            .onSubmit {
                                viewModel.process()
                            }
                    }
                    .frame(height: 55)
                }
            }
        }
    }
    
    // New: Preset selector to resolve the missing symbol error.
    private var presetSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preset")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Picker("Preset", selection: $viewModel.selectedPreset) {
                ForEach(KernelPresets.all.map { $0.name }, id: \.self) { name in
                    Text(name).tag(name)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPreset) { newValue in
                viewModel.applyPreset(newValue)
            }
        }
    }

    // MARK: - Parameters section (Stride & Padding with fixed visible numbers)
    private var parameterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Parameters")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            // Stride
            HStack {
                Text("Stride")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(viewModel.stride)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(minWidth: 32, alignment: .trailing)
                Stepper("", value: $viewModel.stride, in: 1...8, step: 1, onEditingChanged: { _ in
                    viewModel.process()
                })
                .labelsHidden()
                .tint(.blue)
            }
            
            // Padding
            HStack {
                Text("Padding")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(viewModel.padding)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(minWidth: 32, alignment: .trailing)
                Stepper("", value: $viewModel.padding, in: 0...8, step: 1, onEditingChanged: { _ in
                    viewModel.process()
                })
                .labelsHidden()
                .tint(.blue)
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(glassStroke, lineWidth: 1))
        .accessibilityElement(children: .contain)
    }

    // MARK: - Center: Feature map display
    private var mainFeatureDisplay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(glassStroke, lineWidth: 1))
            if let img = viewModel.featureMap {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(8)
            } else {
                VStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Processing...")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.footnote)
                }
                .padding()
            }
        }
        .frame(height: 360)
    }

    // MARK: - Center: Activation toggle row
    private var activationToggleRow: some View {
        Toggle(isOn: $viewModel.isReLUActive) {
            Text("Apply ReLU Activation")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
        }
        .tint(.blue)
        .onChange(of: viewModel.isReLUActive) { _ in
            viewModel.process()
        }
    }

    // MARK: - Footer
    private var navigationFooter: some View {
        HStack {
            Spacer()
            Button {
                // Re-run with current settings
                viewModel.process()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Reprocess")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func dashboardCard<Content: View>(width: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        VStack { content() }
            .padding(28)
            .frame(width: width, height: cardHeight)
            .background(glassBackground)
            .cornerRadius(32)
            .overlay(RoundedRectangle(cornerRadius: 32).stroke(glassStroke, lineWidth: 1.5))
    }
}
