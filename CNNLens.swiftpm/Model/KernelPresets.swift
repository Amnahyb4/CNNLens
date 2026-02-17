//
//  KernelPresets.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 26/08/1447 AH.
//
import SwiftUI

struct KernelPreset: Identifiable {
    let id = UUID()
    let name: String
    let matrix: [[Double]]
    let description: String
}

struct KernelPresets {
    static let all: [KernelPreset] = [
        KernelPreset(name: "Blur", matrix: [
            [0.11, 0.11, 0.11], [0.11, 0.11, 0.11], [0.11, 0.11, 0.11]
        ], description: "Averages neighboring pixels to smooth the image. Useful for reducing noise before further processing."),
        
        KernelPreset(name: "Edge", matrix: [
            [-1, -1, -1], [-1, 8, -1], [-1, -1, -1]
        ], description: "Highlights sharp intensity changes. This is fundamental for detecting shapes and boundaries."),
        
        KernelPreset(name: "Sharpen", matrix: [
            [0, -1, 0], [-1, 5, -1], [0, -1, 0]
        ], description: "Increases contrast between adjacent pixels, making fine details stand out more."),
        
        KernelPreset(name: "Emboss", matrix: [
            [-2, -1, 0], [-1, 1, 1], [0, 1, 2]
        ], description: "Highlights directional intensity shifts, giving the image a 3D-like shadowed effect.")
    ]
}
