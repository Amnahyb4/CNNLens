//
//  ConvolutionViewModel.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
//
import SwiftUI

class ConvolutionViewModel: ObservableObject {
    @Published var kernel: [[Double]] = KernelPresets.all[0].matrix
    @Published var selectedPreset: String = "Blur"
    @Published var isReLUActive: Bool = false
    @Published var featureMap: UIImage?
    @Published var stride: Int = 1
    @Published var padding: Int = 0
    
    let originalImage: UIImage
    
    init(image: UIImage) {
        self.originalImage = image
        process()
    }
    
    func process() {
        DispatchQueue.global(qos: .userInteractive).async {
            var result = ConvolutionEngine.apply(image: self.originalImage, kernel: self.kernel)
            if self.isReLUActive, let img = result {
                result = ActivationService.applyReLU(to: img)
            }
            DispatchQueue.main.async { self.featureMap = result }
        }
    }
    
    // Added: allow the view to select a preset cleanly.
    func applyPreset(_ name: String) {
        guard let preset = KernelPresets.all.first(where: { $0.name == name }) else { return }
        selectedPreset = preset.name
        kernel = preset.matrix
        process()
    }
    
    var currentDescription: String {
        KernelPresets.all.first(where: { $0.name == selectedPreset })?.description ?? ""
    }
}
