//
//  KernelPresets.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
//
import Foundation

struct KernelPreset {
    let name: String
    let matrix: [[Double]]
    let description: String
}

struct KernelPresets {
    static let all: [KernelPreset] = [
        KernelPreset(name: "Blur", matrix: Array(repeating: Array(repeating: 0.11, count: 3), count: 3),
                     description: "Averages neighboring pixels to smooth the image. Useful for reducing noise before further processing."),
        KernelPreset(name: "Edge", matrix: [[-1, -1, -1], [-1, 8, -1], [-1, -1, -1]],
                     description: "Highlights sharp changes in intensity. This kernel subtracts the neighbors from the center to find outlines."),
        KernelPreset(name: "Sharpen", matrix: [[0, -1, 0], [-1, 5, -1], [0, -1, 0]],
                     description: "Increases contrast between adjacent pixels, making textures and fine details stand out more."),
        KernelPreset(name: "Emboss", matrix: [[-2, -1, 0], [-1, 1, 1], [0, 1, 2]],
                     description: "Creates a 3D shadow effect by comparing diagonal gradients across the pixel grid.")
    ]
}
