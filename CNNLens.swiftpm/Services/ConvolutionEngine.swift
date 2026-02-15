//
//  ConvolutionEngine.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
//
import UIKit
import Accelerate

// --- Convolution Math ---
struct ConvolutionEngine {
    static func apply(image: UIImage, kernel: [[Double]]) -> UIImage? {
        // Flatten and scale kernel to Int16 as required by vImage
        let flatKernel = kernel.flatMap { $0 }.map { Float($0) }
        guard
            let cgImage = image.cgImage,
            let kernelWidthInt = kernel.first?.count,
            kernelWidthInt > 0
        else {
            return nil
        }

        let kernelHeight: UInt32 = UInt32(kernel.count)
        let kernelWidth: UInt32 = UInt32(kernelWidthInt)

        // vImage expects Int16 kernel with a divisor
        let matrix: [Int16] = flatKernel.map { Int16($0 * 100) }
        let divisor: Int32 = (flatKernel.reduce(0, +) == 0) ? 1 : 100

        // Use ARGB8888 format because we call vImageConvolve_ARGB8888
        let argb8888Format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), // ARGB
            renderingIntent: .defaultIntent
        )!

        // Build source buffer as var so we can pass it inout
        guard var sourceBuffer = try? vImage_Buffer(cgImage: cgImage, format: argb8888Format) else {
            return nil
        }

        // Create destination buffer with same dimensions and bpp
        var destBuffer = try! vImage_Buffer(
            width: Int(sourceBuffer.width),
            height: Int(sourceBuffer.height),
            bitsPerPixel: argb8888Format.bitsPerPixel
        )

        // Perform convolution
        let error: vImage_Error = matrix.withUnsafeBufferPointer { kernelPtr in
            vImageConvolve_ARGB8888(
                &sourceBuffer,
                &destBuffer,
                nil,                // tempBuffer
                0,                  // srcOffsetToROI_X
                0,                  // srcOffsetToROI_Y
                kernelPtr.baseAddress,
                kernelHeight,
                kernelWidth,
                divisor,
                nil,                // backgroundColor (ignored with kvImageEdgeExtend)
                vImage_Flags(kvImageEdgeExtend)
            )
        }

        defer {
            // Free buffers before exiting
            sourceBuffer.free()
            destBuffer.free()
        }

        // Build output image if successful
        guard error == kvImageNoError,
              let outCGImage = try? destBuffer.createCGImage(format: argb8888Format)
        else {
            return nil
        }

        return UIImage(cgImage: outCGImage)
    }
}

// --- ReLU Activation Math ---
struct ActivationService {
    static func applyReLU(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        // Simple ReLU filter: sets negative pixel values to 0
        let filter = CIFilter(name: "CIColorMatrix")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
        filter?.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        filter?.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")

        if let output = filter?.outputImage,
           let cgImage = CIContext().createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
