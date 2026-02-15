//
//  LandingViewModel.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 23/08/1447 AH.
//
import Foundation
import SwiftUI

class LandingViewModel: ObservableObject {
    @Published var config = AppConfig()
    @Published var navigateToSamples: Bool = false
    
    // Logic for button press
    func startExperience() {
        print("Transitioning to CNN explorer...")
        navigateToSamples = true
    }
}
