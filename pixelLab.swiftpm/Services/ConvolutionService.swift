import UIKit
import CoreGraphics

enum ConvolutionService {

    struct Output {
        let buffer: [Float]
        let image: UIImage
    }

    static func convolve3x3(
        input: [Float],
        width: Int,
        height: Int,
        kernel: Kernel,
        normalized01: Bool = true
    ) -> Output {

        let k = kernel.values
        var raw = [Float](repeating: 0, count: width * height)

        func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

        // 1. Precise Convolution Pipeline (High Precision Float)
        for y in 0..<height {
            for x in 0..<width {
                var sum: Float = 0
                for ky in 0..<3 {
                    for kx in 0..<3 {
                        let ix = clamp(x + (kx - 1), 0, width - 1)
                        let iy = clamp(y + (ky - 1), 0, height - 1)
                        let pixel = input[iy * width + ix]
                        let w = Float(k[ky][kx])
                        sum += pixel * w
                    }
                }
                raw[y * width + x] = sum
            }
        }

        // 2. Real Image Processing Normalization
        let displayBuffer: [Float] = {
            if normalized01 {
                let kernelValues = kernel.values.flatMap { $0 }
                let kernelSum = kernelValues.reduce(0, +)
                
                // Determine the range of the raw output
                var minV = Float.greatestFiniteMagnitude
                var maxV = -Float.greatestFiniteMagnitude
                for v in raw {
                    if v < minV { minV = v }
                    if v > maxV { maxV = v }
                }
                let range = maxV - minV

                // MODE A: IMAGE ENHANCEMENT (Sharpening / Smoothing)
                // If kernel sum ≈ 1.0, we preserve the original exposure via clamping.
                // This prevents the "ghostly" washout seen in aggressive sharpening.
                if abs(kernelSum - 1.0) < 0.1 {
                    return raw.map { max(0, min(1, $0)) }
                }
                // MODE B: FEATURE EXTRACTION (Edges / Experimental)
                // For negative sums (-1.00, -4.00) or edge sums (~0.0), stretch the range
                // into visible grayscale. This fixes the "Always Black" issue.
                else if range > 0.00001 {
                    return raw.map { ($0 - minV) / range }
                }
                
                return [Float](repeating: 0, count: raw.count)
            } else {
                return raw.map { max(0, min(255, $0)) }
            }
        }()

        let img = grayscaleImage(from: displayBuffer, width: width, height: height, normalized01: normalized01)
        return Output(buffer: raw, image: img)
    }

    private static func grayscaleImage(from buf: [Float], width: Int, height: Int, normalized01: Bool) -> UIImage {
        let u8: [UInt8] = buf.map { v in
            let scaled = normalized01 ? (v * 255.0) : v
            return UInt8(max(0, min(255, Int(scaled.rounded()))))
        }

        let cfData = CFDataCreate(nil, u8, u8.count)!
        let provider = CGDataProvider(data: cfData)!

        let cg = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )!

        return UIImage(cgImage: cg)
    }
}
