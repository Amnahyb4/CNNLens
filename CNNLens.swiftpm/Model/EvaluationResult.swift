//
//  EvaluationResult.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 02/09/1447 AH.
//

import Foundation

struct EvaluationResult: Equatable {
    var similarityPercent: Double? = nil // nil until first output exists
    var statusText: String = "Not Started"
    var isComplete: Bool = false
}
