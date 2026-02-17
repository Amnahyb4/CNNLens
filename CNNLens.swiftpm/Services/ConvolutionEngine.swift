//
//  ConvolutionEngine.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
//
import UIKit
import CoreImage

class ConvolutionEngine {
    static func apply(image: UIImage, kernel: [[Double]], stride: Int, padding: Int = 0) -> UIImage? {
        // MARK: - 1. Apply Zero-Padding
        // We create a black canvas larger than the original to simulate zero-padding semantics
        let workingImage: UIImage
        if padding > 0 {
            let pad = CGFloat(padding)
            let newSize = CGSize(width: image.size.width + 2 * pad, height: image.size.height + 2 * pad)
            UIGraphicsBeginImageContextWithOptions(newSize, true, image.scale)
            
            UIColor.black.setFill() // Zero-padding uses black (0) values
            UIRectFill(CGRect(origin: .zero, size: newSize))
            
            image.draw(in: CGRect(x: pad, y: pad, width: image.size.width, height: image.size.height))
            let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            workingImage = paddedImage ?? image
        } else {
            workingImage = image
        }
        
        guard let ciImage = CIImage(image: workingImage) else { return image }
        
        // MARK: - 2. Configure Convolution Math
        let weights = kernel.flatMap { $0 }.map { CGFloat($0) }
        let filter = CIFilter(name: "CIConvolution3X3")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(values: weights, count: 9), forKey: "inputWeights")
        
        // MARK: - 3. VISIBILITY FIX: Handle Zero-Sum Kernels (Edge Detection)
        // Edge kernels sum to 0, which makes the output appear black.
        // We add a bias of 0.5 to shift the results into visible gray tones.
        let kernelSum = weights.reduce(0, +)
        if abs(kernelSum) < 0.01 {
            filter?.setValue(0.5, forKey: "inputBias")
        }
        
        guard var output = filter?.outputImage else { return image }
        
        // MARK: - 4. Apply Stride (Downsampling)
        if stride > 1 {
            let scale = 1.0 / CGFloat(stride)
            output = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        }
        
        // MARK: - 5. Final Render
        let context = CIContext()
        if let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: workingImage.scale, orientation: workingImage.imageOrientation)
        }
        
        return image
    }
}
