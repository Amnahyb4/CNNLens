//
//  ConvolutionView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
//
import SwiftUI

struct ConvolutionView: View {
    @StateObject var viewModel: ConvolutionViewModel
    
    var body: some View {
        ZStack {
            // Align with brand background
            Color(red: 0.02, green: 0.05, blue: 0.12).ignoresSafeArea()
            BackgroundNetworkView().opacity(0.2)
            
            VStack(spacing: 24) {
                StepProgressHeader(currentStep: "Convolution")
                    .padding(.top, 20)
                
                Text("Convolution Playground")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                HStack(alignment: .top, spacing: 20) {
                    // Column 1: Kernel Config
                    VStack(alignment: .leading, spacing: 16) {
                        Text("3×3 Kernel")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Preset buttons with adequate targets
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
                        
                        // Manual Grid
                        VStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { r in
                                HStack(spacing: 8) {
                                    ForEach(0..<3, id: \.self) { c in
                                        TextField("", value: $viewModel.kernel[r][c], format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 65)
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
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(width: 280)
                    
                    // Column 2: Visual Map
                    VStack(spacing: 12) {
                        Text("Feature Map")
                            .font(.caption.smallCaps())
                            .foregroundColor(.blue)
                        if let img = viewModel.featureMap {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320, height: 320)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .accessibilityLabel("Feature map image")
                        } else {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.white.opacity(0.05))
                                .frame(width: 320, height: 320)
                                .overlay(Text("No output yet").foregroundColor(.gray))
                                .accessibilityHidden(true)
                        }
                        
                        // ReLU Toggle Bar with adequate targets
                        HStack(spacing: 0) {
                            Button("None") { viewModel.isReLUActive = false; viewModel.process() }
                                .frame(minHeight: 44)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(!viewModel.isReLUActive ? Color(white: 0.2) : Color.clear)
                                .accessibilityLabel("No activation")
                            Button("ReLU") { viewModel.isReLUActive = true; viewModel.process() }
                                .frame(minHeight: 44)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(viewModel.isReLUActive ? Color(white: 0.2) : Color.clear)
                                .accessibilityLabel("ReLU activation")
                        }
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    
                    // Column 3: Explanation
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What does this detect?")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(viewModel.currentDescription)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("AI Insight", systemImage: "lightbulb.fill")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                            Text("In a real CNN, these kernel values are learned during training, not set by humans.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .frame(width: 280)
                }
                
                Spacer()
                
                // Bottom Navigation
                HStack {
                    Button("Back") {}
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        .frame(minWidth: 88, minHeight: 44)
                    Spacer()
                    Button("Next") {}
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .frame(minWidth: 88, minHeight: 44)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
    }
}
