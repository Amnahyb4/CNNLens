
import Foundation
import SwiftUI

class LandingViewModel: ObservableObject {
    @Published var config = AppConfig()
    @Published var navigateToSamples: Bool = false
    
    // Logic for button press
    func startExperience() {
        navigateToSamples = true
    }
}
