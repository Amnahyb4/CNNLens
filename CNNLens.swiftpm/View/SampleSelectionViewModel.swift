//
//  SampleSelectionViewModel.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 24/08/1447 AH.
//

import Foundation

class SampleSelectionViewModel: ObservableObject {
    @Published var samples: [SampleImage] = [
        SampleImage(name: "Cityscape", imageName: "amsterdam"),
        SampleImage(name: "Feline", imageName: "cat"),
        SampleImage(name: "Nature", imageName: "clif"),
        SampleImage(name: "Beverage", imageName: "drink")
    ]
    
    func selectImage(_ sample: SampleImage) {
        print("Selected: \(sample.name)")
        // Logic to move to the CNN analysis screen goes here
    }
}
