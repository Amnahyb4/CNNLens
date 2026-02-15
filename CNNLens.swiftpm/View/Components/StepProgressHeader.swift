//
//  StepProgressHeader.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 25/08/1447 AH.
//
import SwiftUI

struct StepProgressHeader: View {
    let currentStep: String
    // Scale the whole component. 1.0 ≈ previous size; >1.0 = larger
    var size: CGFloat = 1.3
    
    private let steps: [StepItem] = [
        .init(title: "Input",         icon: .sf("photo.fill")),
        .init(title: "Convolution",   icon: .sf("square.grid.3x3.fill")),
        .init(title: "Feature Maps",  icon: .sf("square.stack.3d.up.fill")),
        .init(title: "Pooling",       icon: .custom),
        .init(title: "Output",        icon: .sf("target"))
    ]
    
    // Derived metrics from size
    private var circleDiameter: CGFloat { 40 * size }
    private var iconSize: CGFloat { 14 * size }
    private var labelFont: Font { .system(size: max(10, 11 * size), weight: .semibold, design: .default) }
    private var minItemWidth: CGFloat { 72 * size }
    private var connectorWidth: CGFloat { 56 * size }
    private var connectorHeight: CGFloat { max(2, 2 * size) }
    private var labelSpacing: CGFloat { 8 * size }
    private var connectorBottomPadding: CGFloat { 20 * size }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(steps.indices, id: \.self) { i in
                let isCurrent = steps[i].title == currentStep
                VStack(spacing: labelSpacing) {
                    ZStack {
                        Circle()
                            .fill(isCurrent ? Color.blue : Color(white: 0.15))
                            .frame(width: circleDiameter, height: circleDiameter)
                        
                        switch steps[i].icon {
                        case .sf(let name):
                            Image(systemName: name)
                                .font(.system(size: iconSize, weight: .semibold))
                                .foregroundColor(isCurrent ? .white : .gray)
                        case .custom:
                            PoolingIcon(size: iconSize, color: isCurrent ? .white : .gray)
                        }
                    }
                    
                    Text(steps[i].title)
                        .font(labelFont)
                        .foregroundColor(isCurrent ? .blue : .gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .accessibilityAddTraits(isCurrent ? [.isSelected] : [])
                }
                .frame(minWidth: minItemWidth)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(steps[i].title)\(isCurrent ? ", current step" : "")")
                
                if i < steps.count - 1 {
                    Capsule()
                        .fill(Color(white: 0.2))
                        .frame(width: connectorWidth, height: connectorHeight)
                        .padding(.bottom, connectorBottomPadding)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

private struct StepItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: StepIcon
}

private enum StepIcon {
    case sf(String)
    case custom // used for Pooling
}

// A composited "pooling" glyph: 3x3 grid with inward diagonal arrows to suggest downsampling.
private struct PoolingIcon: View {
    let size: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Image(systemName: "square.grid.3x3")
                .font(.system(size: size, weight: .regular))
                .foregroundColor(color.opacity(0.75))
            
            Image(systemName: "arrow.down.right.and.arrow.up.left")
                .font(.system(size: size * 0.9, weight: .semibold))
                .foregroundColor(color)
        }
        .accessibilityHidden(true)
    }
}
