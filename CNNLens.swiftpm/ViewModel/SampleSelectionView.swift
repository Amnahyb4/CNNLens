//
//  SampleSelectionView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 24/08/1447 AH.
//
import SwiftUI

struct SampleSelectionView: View {
    @StateObject private var viewModel = SampleSelectionViewModel()
    
    // Two responsive columns with comfortable minimums
    private let columns: [GridItem] = [
        GridItem(.flexible(minimum: 280), spacing: 24, alignment: .top),
        GridItem(.flexible(minimum: 280), spacing: 24, alignment: .top)
    ]
    
    var body: some View {
        ZStack {
            // Brand background
            Color(red: 0.02, green: 0.05, blue: 0.12).ignoresSafeArea()
            BackgroundNetworkView().opacity(0.25)
            
            VStack(spacing: 28) {
                VStack(spacing: 6) {
                    Text("Step 1")
                        .font(.caption.smallCaps())
                        .foregroundColor(.blue)
                    
                    Text("Choose a Sample")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Pick one of these images to explore how a CNN processes it.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 640)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 24)
                
                // 2x2 gallery grid
                LazyVGrid(columns: columns, alignment: .center, spacing: 24) {
                    ForEach(viewModel.samples) { sample in
                        NavigationLink {
                            PreprocessingView(imageName: sample.imageName)
                        } label: {
                            SampleCard(sample: sample)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Sample: \(sample.name)")
                                .accessibilityAddTraits(.isButton)
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(TapGesture().onEnded {
                            viewModel.selectImage(sample)
                        })
                    }
                }
                // Constrain total grid width to keep two columns looking balanced
                .frame(maxWidth: 760)
                .padding(.horizontal, 20)
                
                Spacer(minLength: 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SampleCard: View {
    let sample: SampleImage
    
    private let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = width * 3.0 / 4.0
            
            ZStack(alignment: .bottomLeading) {
                Image(sample.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(shape)
                    .accessibilityHidden(true)
                
                shape
                    .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                    .frame(width: width, height: height)
                
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(shape)
                .frame(width: width, height: height)
                
                Text(sample.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(12)
            }
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 6)
        }
        .aspectRatio(4.0 / 3.0, contentMode: .fit)
        .contentShape(shape)
    }
}

#Preview {
    NavigationStack {
        SampleSelectionView()
            .preferredColorScheme(.dark)
            .dynamicTypeSize(...DynamicTypeSize.accessibility5)
    }
}
