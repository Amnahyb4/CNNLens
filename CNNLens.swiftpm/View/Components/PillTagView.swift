//
//  PillTagView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 02/09/1447 AH.
//

import SwiftUI

struct PillTagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.white.opacity(0.78))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
            .accessibilityLabel("Tag: \(text)")
    }
}
