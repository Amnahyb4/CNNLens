
import SwiftUI

struct ChallengeInfoSheetView: View {

    let title: String
    let educationalText: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.text)

                    Text(educationalText)
                        .font(.body)
                        .foregroundStyle(Theme.secondary)
                        .lineSpacing(6)

                }
                .padding(24)
            }
            .background(Theme.bgTop.ignoresSafeArea())
            .navigationTitle("About This Concept")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large]) // HIG recommended
        .presentationDragIndicator(.visible)
    }
}

