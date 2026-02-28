
import SwiftUI

struct PreprocessGateView: View {
    @Binding var options: PreprocessOptions
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("These steps standardize the input so your kernel results are consistent.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                }

                Section("Options") {
                    Toggle("Resize", isOn: $options.resizeOn)
                        .accessibilityHint("Standardizes image dimensions.")

                    Toggle("Normalize", isOn: $options.normalizeOn)
                        .accessibilityHint("Scales pixel values to the 0 to 1 range.")

                    Toggle("Grayscale", isOn: $options.grayscaleOn)
                        .accessibilityHint("Uses a single intensity channel.")
                }
            }
            .navigationTitle("Preprocessing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button {
                        onContinue()
                        dismiss()
                    } label: {
                        Label("Continue to Lab", systemImage: "arrow.right")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)

                    // Optional subtle note
                    Text("You can change these options later by restarting the lab.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.regularMaterial)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
