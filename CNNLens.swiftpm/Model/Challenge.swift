//
//  Challenge.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 02/09/1447 AH.
//
import Foundation

enum ChallengeID: String, CaseIterable, Identifiable {
    case smoothing
    case sharpening
    case sobelX
    case laplacian

    var id: String { rawValue }
}

struct Challenge: Identifiable, Equatable {
    let id: ChallengeID

    // UI
    let title: String
    let tag: String
    let oneLine: String

    // Playground content
    let goal: String
    let hints: [String]
    let criteria: [String]
    let educationalText: String

    // Logic
    let idealKernel: Kernel
    let similarityThreshold: Double
}

enum ChallengeFactory {

    static func make(_ id: ChallengeID) -> Challenge {
        switch id {

        case .smoothing:
            var k = Kernel.zeros()
            k.values = [
                [1.0/9.0, 1.0/9.0, 1.0/9.0],
                [1.0/9.0, 1.0/9.0, 1.0/9.0],
                [1.0/9.0, 1.0/9.0, 1.0/9.0]
            ]
            return Challenge(
                id: .smoothing,
                title: "Smoothing",
                tag: "Low Frequency",
                oneLine: "Reduce noise using a low-pass filter.",
                goal: "Create a filter that reduces high-frequency noise while preserving overall image structure.",
                hints: [
                    "All weights should be positive",
                    "Kernel sum should equal 1",
                    "Symmetry improves smoothing"
                ],
                criteria: [
                    "Kernel Sum ≈ 1",
                    "Output similarity > 90%"
                ],
                educationalText: """
A smoothing filter reduces high-frequency noise by averaging pixel values with their neighbors. It acts as a low-pass filter, allowing slow intensity changes to pass while suppressing rapid ones.

Common uses: noise reduction before edge detection, image preprocessing, depth-of-field simulation.
""",
                idealKernel: k,
                similarityThreshold: 90
            )

        case .sharpening:
            var k = Kernel.zeros()
            k.values = [
                [0, -1, 0],
                [-1, 5, -1],
                [0, -1, 0]
            ]
            return Challenge(
                id: .sharpening,
                title: "Sharpening",
                tag: "High Frequency",
                oneLine: "Enhance details using a high-pass component.",
                goal: "Enhance edges and fine detail while keeping the image stable.",
                hints: [
                    "Sharpening often uses negative weights around the center",
                    "The center weight is usually larger",
                    "Too much sharpening can amplify noise"
                ],
                criteria: [
                    "Clear edge enhancement",
                    "Output similarity > 90%"
                ],
                educationalText: """
Sharpening enhances edges and fine details by amplifying high-frequency components. It works by subtracting a blurred version of the image from the original.

Common uses: enhancing scanned documents, improving perceived focus, medical imaging.
""",
                idealKernel: k,
                similarityThreshold: 90
            )

        case .sobelX:
            var k = Kernel.zeros()
            k.values = [
                [-1, 0, 1],
                [-2, 0, 2],
                [-1, 0, 1]
            ]
            return Challenge(
                id: .sobelX,
                title: "Vertical Edge Detection",
                tag: "Gradient",
                oneLine: "Detect vertical edges using Sobel X.",
                goal: "Detect vertical edges by responding strongly to left-to-right intensity changes.",
                hints: [
                    "Edge detectors often have kernel sum close to 0",
                    "Positive and negative weights indicate direction",
                    "Try keeping the kernel pattern balanced"
                ],
                criteria: [
                    "Kernel Sum ≈ 0",
                    "Output similarity > 90%"
                ],
                educationalText: """
The Sobel X operator detects vertical edges by computing the horizontal gradient of the image. It highlights regions where pixel intensity changes sharply from left to right.

Common uses: lane detection in autonomous vehicles, object boundary detection, feature extraction in computer vision.
""",
                idealKernel: k,
                similarityThreshold: 90
            )

        case .laplacian:
            var k = Kernel.zeros()
            k.values = [
                [0, -1, 0],
                [-1, 4, -1],
                [0, -1, 0]
            ]
            return Challenge(
                id: .laplacian,
                title: "Laplacian",
                tag: "Second Derivative",
                oneLine: "Detect edges using a second derivative.",
                goal: "Detect regions of rapid intensity change using second-order derivatives.",
                hints: [
                    "Second derivatives often have kernel sum close to 0",
                    "The Laplacian is not directional",
                    "Edges appear where intensity changes quickly"
                ],
                criteria: [
                    "Kernel Sum ≈ 0",
                    "Output similarity > 90%"
                ],
                educationalText: """
The Laplacian operator computes the second spatial derivative of an image, highlighting regions of rapid intensity change in all directions simultaneously.
Unlike Sobel (which is directional), the Laplacian is isotropic — it responds equally to edges in any direction. The kernel sum is zero, so flat regions produce no response.
Common uses: blob detection, edge sharpening, finding zero-crossings for precise edge localization.
""",
                idealKernel: k,
                similarityThreshold: 90
            )
        }
    }
}
