//
//  AppFlowViewModel.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 03/09/1447 AH.
//
import SwiftUI

@MainActor
final class AppFlowViewModel: ObservableObject {

    // Selected from Screen 2
    @Published var selectedSample: SampleImage? = nil

    // Selected from Screen 3
    @Published var selectedChallenge: Challenge? = nil

    // Navigation
    @Published var path: [Route] = []

    enum Route: Hashable {
        case sample
        case challenge
        case playground
    }

    func goToSample() {
        path = [.sample]
    }

    func goToChallenges() {
        guard selectedSample != nil else { return }
        path.append(.challenge)
    }

    func goToPlayground() {
        guard selectedSample != nil, selectedChallenge != nil else { return }
        path.append(.playground)
    }

    func resetToLanding() {
        selectedSample = nil
        selectedChallenge = nil
        path = []
    }
}

