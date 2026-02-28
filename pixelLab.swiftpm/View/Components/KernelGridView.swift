import SwiftUI

struct KernelGridView: View {
    @Binding var kernel: Kernel
    let onChange: (Int, Int, Double) -> Void

    @FocusState private var focusedCell: CellID?

    struct CellID: Hashable {
        let r: Int
        let c: Int
    }

    @State private var text: [[String]] = Array(
        repeating: Array(repeating: "0", count: 3),
        count: 3
    )

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { r in
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { c in
                        cell(row: r, col: c)
                    }
                }
            }
        }
        .onAppear { syncFromKernel() }
        .onChange(of: kernel) { _ in
            syncFromKernel()
        }
        // Refinement: Marks this as a single logical area with instructions
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Kernel Matrix")
        .accessibilityHint("A 3 by 3 grid of numbers that define the image filter.")
    }

    private func cell(row: Int, col: Int) -> some View {
        let id = CellID(r: row, c: col)
        let isFocused = focusedCell == id

        return TextField("", text: Binding(
            get: { text[row][col] },
            set: { newText in
                let sanitized = newText
                    .replacingOccurrences(of: ",", with: ".")
                    .filter { "0123456789.-".contains($0) }

                text[row][col] = sanitized

                if let v = Double(sanitized),
                   sanitized != "-" && sanitized != "." && sanitized != "-." {
                    kernel.set(row, col, v)
                    onChange(row, col, v)
                }
            })
        )
        .keyboardType(.numbersAndPunctuation)
        .multilineTextAlignment(.center)
        .font(.title3.weight(.semibold).monospacedDigit()) // Refinement: monospaced prevents text 'jitter'
        .foregroundStyle(Theme.text)
        .frame(width: 72, height: 72)
        .background(Theme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? Theme.accent.opacity(0.9) : Color.white.opacity(0.08),
                        lineWidth: isFocused ? 2 : 1)
        )
        .focused($focusedCell, equals: id)
        .onTapGesture { focusedCell = id }
        .onSubmit { commit(row: row, col: col) }
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        // Accessibility Refinement: Added a descriptive hint for editing
        .accessibilityLabel("Row \(row + 1), Column \(col + 1)")
        .accessibilityValue(text[row][col].isEmpty ? "zero" : text[row][col])
        .accessibilityHint("Double tap to enter a new value for this part of the filter.")
    }

    private func commit(row: Int, col: Int) {
        let raw = text[row][col].replacingOccurrences(of: ",", with: ".")

        guard let v = Double(raw) else {
            text[row][col] = "0"
            kernel.set(row, col, 0)
            onChange(row, col, 0)
            return
        }

        kernel.set(row, col, v)
        onChange(row, col, v)
        text[row][col] = format(v)
    }

    private func syncFromKernel() {
        for r in 0..<3 {
            for c in 0..<3 {
                text[r][c] = format(kernel.get(r, c))
            }
        }
    }

    private func format(_ v: Double) -> String {
        // Simple precision check: $$|v_{rounded} - v| < \epsilon$$
        if abs(v.rounded() - v) < 0.0001 { return String(Int(v)) }
        return String(format: "%.2f", v)
    }
}
