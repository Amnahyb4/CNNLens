//
//  mageProcessor.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 25/08/1447 AH.
//
import UIKit
import CoreImage

final class ImageProcessor: @unchecked Sendable {
    static let shared = ImageProcessor()
    private let context = CIContext()

    func process(imageName: String, state: PreprocessingState) -> UIImage? {
        // Load original image from assets
        guard let uiImage = UIImage(named: imageName) else { return nil }
        var ciImage = CIImage(image: uiImage)
        
        // 1. Grayscale (Mono Effect)
        if state.isGrayscale {
            let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono")
            grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            ciImage = grayscaleFilter?.outputImage ?? ciImage
        }
        
        // 2. Normalization (0-1 Scaling)
        if state.isNormalized {
            // In a real CNN, this maps 0-255 pixels to a 0.0-1.0 range.
            // Visually, we simulate this by standardizing contrast and brightness.
            let normalizationFilter = CIFilter(name: "CIColorControls")
            normalizationFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            normalizationFilter?.setValue(1.0, forKey: kCIInputSaturationKey)
            normalizationFilter?.setValue(0.0, forKey: kCIInputBrightnessKey)
            normalizationFilter?.setValue(1.1, forKey: kCIInputContrastKey) // Standardized pop
            ciImage = normalizationFilter?.outputImage ?? ciImage
        }
        
        // 3. Resize to 224 x 224 (Standard CNN Input)
        if state.isResized {
            let targetSize = CGSize(width: 224, height: 224)
            let scaleX = targetSize.width / (ciImage?.extent.width ?? 1)
            let scaleY = targetSize.height / (ciImage?.extent.height ?? 1)
            ciImage = ciImage?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        }

        // Render the final processed image
        guard let output = ciImage,
              let cgImage = context.createCGImage(output, from: output.extent) else { return uiImage }
        
        return UIImage(cgImage: cgImage)
    }
}
