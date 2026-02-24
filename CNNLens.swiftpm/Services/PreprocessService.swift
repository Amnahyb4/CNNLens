//
//  PreprocessService.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 03/09/1447 AH.
//

import UIKit
import CoreGraphics

enum PreprocessService {

    struct Result {
        let displayInput: UIImage            // what you show in "Original"
        let gray: [Float]                    // 0...1
        let width: Int
        let height: Int
        let optionsKey: String               // for caching
    }

    static func run(
        image: UIImage,
        targetSize: Int = 512,
        options: PreprocessOptions
    ) -> Result? {

        // 1) Resize (ON by your setting)
        let resized = options.resizeOn ? resizeToSquare(image, size: targetSize) : image

        guard let cg = resized.cgImage else { return nil }

        // 2) Convert to grayscale buffer (0..255)
        guard let (u8, w, h) = grayscaleU8(cgImage: cg) else { return nil }

        // 3) Normalize (ON by your setting) -> Float 0..1
        let gray: [Float]
        if options.normalizeOn {
            gray = u8.map { Float($0) / 255.0 }
        } else {
            gray = u8.map { Float($0) } // 0..255 (not recommended, but supported)
        }

        // 4) Options key (for cache)
        let key = "r\(options.resizeOn ? 1 : 0)-n\(options.normalizeOn ? 1 : 0)-g\(options.grayscaleOn ? 1 : 0)-s\(targetSize)"

        return Result(
            displayInput: resized,
            gray: gray,
            width: w,
            height: h,
            optionsKey: key
        )
    }

    // MARK: - Helpers

    private static func resizeToSquare(_ image: UIImage, size: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        }
    }

    private static func grayscaleU8(cgImage: CGImage) -> ([UInt8], Int, Int)? {
        let width = cgImage.width
        let height = cgImage.height

        // 8-bit grayscale
        let bytesPerRow = width
        var data = [UInt8](repeating: 0, count: width * height)

        guard let ctx = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }

        ctx.interpolationQuality = .high
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        return (data, width, height)
    }
}
