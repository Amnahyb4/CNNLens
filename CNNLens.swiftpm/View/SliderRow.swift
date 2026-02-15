import SwiftUI

struct SliderRow: View {
    let label: String
    @Binding var value: Int
    // In the current call sites this is passed as a string like "1" or "0".
    // We'll interpret it as the minimum allowed value and clamp to a reasonable max.
    let range: String
    
    private var minValue: Int { Int(range) ?? 0 }
    private var maxValue: Int {
        // Provide sensible defaults based on the label if possible
        switch label.lowercased() {
        case "stride":  return 4
        case "padding": return 4
        default:        return max(minValue, 10)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .foregroundColor(.white)
                Text("min \(minValue), max \(maxValue)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Stepper(value: Binding(
                get: { value },
                set: { newVal in
                    value = min(max(newVal, minValue), maxValue)
                }
            ), in: minValue...maxValue) {
                Text("\(value)")
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .frame(minWidth: 28, alignment: .trailing)
            }
            .labelsHidden()
        }
        .padding(.vertical, 6)
    }
}
