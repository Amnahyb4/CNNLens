
import Foundation

class SampleSelectionViewModel: ObservableObject {
    @Published var samples: [SampleImage] = [
        SampleImage(name: "Cityscape", imageName: "amsterdam"),
        SampleImage(name: "Feline", imageName: "cat"),
        SampleImage(name: "Nature", imageName: "clif"),
        SampleImage(name: "Beverage", imageName: "drink")
    ]
    
    // Track the selected sample and navigation state
    @Published var selectedSample: SampleImage? = nil
    @Published var navigateToChallenges: Bool = false
    
    func selectImage(_ sample: SampleImage) {
        selectedSample = sample
        print("Selected: \(sample.name)")
        // Trigger navigation to ChallengeSelectionView
        navigateToChallenges = true
    }
}
