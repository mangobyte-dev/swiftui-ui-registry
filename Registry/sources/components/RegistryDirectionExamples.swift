import SwiftUI

/// Read `layoutDirection` and use leading/trailing alignment instead of left/right geometry.
/// No registry replacement is needed because SwiftUI propagates direction through the environment.
private struct RegistryDirectionExamples: View {
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(layoutDirection == .leftToRight ? "Left to right" : "Right to left")
                .font(.headline)

            HStack {
                Image(systemName: "person.crop.circle")
                    .accessibilityHidden(true)
                Text("Account")
                Spacer()
                Image(systemName: "chevron.forward")
                    .accessibilityHidden(true)
            }
            .padding()
            .background(.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview("Direction Left to Right") {
    RegistryDirectionExamples().environment(\.layoutDirection, .leftToRight)
}

#Preview("Direction Right to Left") {
    RegistryDirectionExamples().environment(\.layoutDirection, .rightToLeft)
}

#Preview("Direction Dark") {
    RegistryDirectionExamples().preferredColorScheme(.dark)
}

#Preview("Direction Accessibility Size") {
    RegistryDirectionExamples().dynamicTypeSize(.accessibility3)
}
