import SwiftUI

struct ControlHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .imageScale(.medium)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}
