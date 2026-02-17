//
//  ConvolutionViewModel.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
import SwiftUI

class ConvolutionViewModel: ObservableObject {
    @Published var kernel: [[Double]] = KernelPresets.all[0].matrix
    @Published var selectedPreset: String = "Blur"
    @Published var isReLUActive: Bool = false
    @Published var featureMap: UIImage?
    @Published var stride: Int = 1
    @Published var padding: Int = 0
    
    // DATA LINEAGE: This image is guaranteed to be the 224x224 grayscale output
    let inputImage: UIImage

    init(image: UIImage) {
        self.inputImage = image // Properly assigned from the Preprocessing gateway
        process()
    }

    /// The Reactive Engine: Triggers every time a parameter changes
    func process() {
        // 1. Capture the current kernel state on the Main Thread immediately
        let currentKernel = self.kernel
        let currentStride = self.stride
        let currentPadding = self.padding
        
        DispatchQueue.global(qos: .userInteractive).async {
            // 2. Use the CAPTURED values, not 'self.kernel'
            var result = ConvolutionEngine.apply(
                image: self.inputImage,
                kernel: currentKernel, // Use local copy
                stride: currentStride,
                padding: currentPadding
            )
            
            if self.isReLUActive {
                result = self.applyReLU(to: result)
            }
            
            DispatchQueue.main.async {
                self.featureMap = result
            }
        }
    }

    func applyPreset(_ name: String) {
        if let preset = KernelPresets.all.first(where: { $0.name == name }) {
            self.selectedPreset = preset.name
            self.kernel = preset.matrix
            process()
        }
    }

    private func applyReLU(to image: UIImage?) -> UIImage? {
        guard let uiImage = image, let ciImage = CIImage(image: uiImage) else { return image }
        
        // Clamps all pixel values below zero to exactly zero to reveal sparse features
        let filter = CIFilter(name: "CIColorMatrix")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        
        let context = CIContext()
        if let output = filter?.outputImage, let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }
    
    var currentDescription: String {
        KernelPresets.all.first(where: { $0.name == selectedPreset })?.description ?? ""
    }
}
