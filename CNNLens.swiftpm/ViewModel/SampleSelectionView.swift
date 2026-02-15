//
//  SampleSelectionView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 24/08/1447 AH.
//
import SwiftUI

private enum Design {
    enum Colors {
        static let background = Color(red: 0.02, green: 0.05, blue: 0.12)
        static let step = Color.blue
        static let title = Color.white
        static let description = Color.gray
        static let stroke = Color.blue.opacity(0.35)
        static let overlayGradient = [Color.clear, Color.black.opacity(0.6)]
        static let cardShadow = Color.black.opacity(0.25)
    }
    enum Metrics {
        static let gridMinColumn: CGFloat = 280
        static let gridSpacing: CGFloat = 24
        static let gridMaxWidth: CGFloat = 760
        static let sectionMaxWidth: CGFloat = 640
        static let sectionHPadding: CGFloat = 20
        static let sectionTopPadding: CGFloat = 24
        static let titleSpacing: CGFloat = 6
        static let cardCornerRadius: CGFloat = 18
        static let cardShadowRadius: CGFloat = 8
        static let cardShadowX: CGFloat = 0
        static let cardShadowY: CGFloat = 6
        static let cardTextPadding: CGFloat = 12
        static let backgroundOpacity: CGFloat = 0.25
    }
}

struct SampleSelectionView: View {
    @StateObject private var viewModel = SampleSelectionViewModel()
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(minimum: Design.Metrics.gridMinColumn), spacing: Design.Metrics.gridSpacing, alignment: .top),
            GridItem(.flexible(minimum: Design.Metrics.gridMinColumn), spacing: Design.Metrics.gridSpacing, alignment: .top)
        ]
    }
    
    var body: some View {
        ZStack {
            // Brand background
            Design.Colors.background.ignoresSafeArea()
            BackgroundNetworkView().opacity(Design.Metrics.backgroundOpacity)
            
            VStack(spacing: Design.Metrics.gridSpacing) {
                header
                    .padding(.top, Design.Metrics.sectionTopPadding)
                
                // 2x2 gallery grid
                LazyVGrid(columns: columns, alignment: .center, spacing: Design.Metrics.gridSpacing) {
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
                .frame(maxWidth: Design.Metrics.gridMaxWidth)
                .padding(.horizontal, Design.Metrics.sectionHPadding)
                
                Spacer(minLength: 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: Design.Metrics.titleSpacing) {
            Text("Step 1")
                .font(.caption.smallCaps())
                .foregroundColor(Design.Colors.step)
            
            Text("Choose a Sample")
                .font(.title.bold())
                .foregroundColor(Design.Colors.title)
                .accessibilityAddTraits(.isHeader)
            
            Text("Pick one of these images to explore how a CNN processes it.")
                .font(.body)
                .foregroundColor(Design.Colors.description)
                .multilineTextAlignment(.center)
                .frame(maxWidth: Design.Metrics.sectionMaxWidth)
                .padding(.horizontal, Design.Metrics.sectionHPadding)
        }
    }
}

private struct SampleCard: View {
    let sample: SampleImage
    private let shape = RoundedRectangle(cornerRadius: Design.Metrics.cardCornerRadius, style: .continuous)
    
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
                    .stroke(Design.Colors.stroke, lineWidth: 1)
                    .frame(width: width, height: height)
                
                LinearGradient(colors: Design.Colors.overlayGradient, startPoint: .top, endPoint: .bottom)
                    .clipShape(shape)
                    .frame(width: width, height: height)
                
                Text(sample.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(Design.Metrics.cardTextPadding)
            }
            .frame(width: width, height: height)
            .shadow(color: Design.Colors.cardShadow, radius: Design.Metrics.cardShadowRadius, x: Design.Metrics.cardShadowX, y: Design.Metrics.cardShadowY)
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
