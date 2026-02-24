
import UIKit
import CoreGraphics

enum ConvolutionService {

    struct Output {
        let buffer: [Float]   // same size, clamped 0..1 if normalized input
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
        var out = [Float](repeating: 0, count: width * height)

        func clamp(_ v: Int, _ lo: Int, _ hi: Int) -> Int { max(lo, min(hi, v)) }

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

                out[y * width + x] = sum
            }
        }

        // For display: clamp to 0..1 if normalized input
        let clamped: [Float] = normalized01
            ? out.map { max(0, min(1, $0)) }
            : out.map { max(0, min(255, $0)) }

        let img = grayscaleImage(from: clamped, width: width, height: height, normalized01: normalized01)
        return Output(buffer: clamped, image: img)
    }

    private static func grayscaleImage(from buf: [Float], width: Int, height: Int, normalized01: Bool) -> UIImage {
        let u8: [UInt8] = buf.map { v in
            if normalized01 {
                return UInt8(max(0, min(255, Int(v * 255.0))))
            } else {
                return UInt8(max(0, min(255, Int(v))))
            }
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

