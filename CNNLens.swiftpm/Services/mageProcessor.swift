//
//  mageProcessor.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 25/08/1447 AH.
//
import UIKit
import CoreImage

struct ImageProcessor {
    static func process(imageName: String, state: PreprocessingState) -> UIImage? {
        guard var image = UIImage(named: imageName) else { return nil }
        
        // 1. REAL RESIZE to 224x224
        if state.isResized {
            let targetSize = CGSize(width: 224, height: 224)
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            image = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
        }
        
        // 2. REAL GRAYSCALE CONVERSION
        if state.isGrayscale {
            let ciImage = CIImage(image: image)
            let grayscale = ciImage?.applyingFilter("CIPhotoEffectMono")
            let context = CIContext()
            if let grayscale = grayscale,
               let cgImage = context.createCGImage(grayscale, from: grayscale.extent) {
                image = UIImage(cgImage: cgImage)
            }
        }
        
        // Note: Normalization is simulated visually here via brightness
        // In a real CNN, this is handled during Tensor conversion.
        return image
    }
}
