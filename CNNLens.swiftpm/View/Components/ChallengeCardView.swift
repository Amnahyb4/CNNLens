//
//  ChallengeCardView.swift
//  CNNLens
//
//  Created by Amnah Albrahim on 02/09/1447 AH.
import SwiftUI

struct ChallengeRowCard: View {
    let challenge: Challenge
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(challenge.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.text)

                    Text(challenge.oneLine)
                        .font(.body)
                        .foregroundStyle(Theme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                }

                Spacer(minLength: 12)

                PillTagView(text: challenge.tag)
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Theme.cardSelected : Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(isSelected ? Theme.accent : Theme.border,
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Double tap to select \(challenge.title).")
    }
}
