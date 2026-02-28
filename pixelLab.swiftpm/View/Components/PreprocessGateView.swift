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
                        // Grouping this text ensures it is read as a single introductory block
                        .accessibilityLabel("Introduction: These steps standardize the image input for consistent results.")
                }

                Section("Options") {
                    Toggle("Resize", isOn: $options.resizeOn)
                        .accessibilityHint("Standardizes image dimensions to 512 pixels.")

                    Toggle("Normalize", isOn: $options.normalizeOn)
                        .accessibilityHint("Scales pixel values to a range between 0 and 1.")

                    Toggle("Grayscale", isOn: $options.grayscaleOn)
                        .accessibilityHint("Converts the image to a single intensity channel.")
                }
            }
            .navigationTitle("Preprocessing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .accessibilityHint("Closes the preprocessing options and returns to the previous screen.")
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
                    // Added a clear hint for the primary lab entry
                    .accessibilityHint("Processes the image with your chosen options and enters the laboratory.")

                    Text("You can change these options later by restarting the lab.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Note: Preprocessing can be adjusted later by restarting the lab.")
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
