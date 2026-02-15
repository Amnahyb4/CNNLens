//
//  PreprocessingViewModel.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 25/08/1447 AH.
//
import SwiftUI

class PreprocessingViewModel: ObservableObject {
    @Published var state = PreprocessingState() {
        didSet { applyProcessing() }
    }
    
    @Published var processedImage: UIImage?
    let originalImageName: String
    
    init(selectedImageName: String) {
        self.originalImageName = selectedImageName
        applyProcessing()
    }
    
    func applyProcessing() {
        // Real-time processing of the image based on toggle states
        self.processedImage = ImageProcessor.process(
            imageName: originalImageName,
            state: state
        )
    }
}
