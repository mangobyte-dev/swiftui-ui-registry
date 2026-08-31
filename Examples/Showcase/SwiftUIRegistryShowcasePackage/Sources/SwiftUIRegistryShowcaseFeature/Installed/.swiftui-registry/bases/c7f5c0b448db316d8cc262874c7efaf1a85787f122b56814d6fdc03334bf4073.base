import SwiftUI

/// Use SwiftUI's native `aspectRatio(_:contentMode:)` modifier at the call site.
/// No registry wrapper is needed because the native modifier already preserves layout proposals.
private struct RegistryAspectRatioExamples: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Video, 16:9")
                .font(.headline)
            Color.indigo
                .overlay {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                }
                .aspectRatio(16.0 / 9.0, contentMode: .fit)
                .accessibilityLabel("Video placeholder")

            Text("Avatar, 1:1")
                .font(.headline)
            Color.teal
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 160)
                .accessibilityLabel("Avatar placeholder")
        }
        .padding()
    }
}

#Preview("Aspect Ratio") {
    RegistryAspectRatioExamples()
}

#Preview("Aspect Ratio Dark") {
    RegistryAspectRatioExamples().preferredColorScheme(.dark)
}

#Preview("Aspect Ratio Right to Left") {
    RegistryAspectRatioExamples().environment(\.layoutDirection, .rightToLeft)
}

#Preview("Aspect Ratio Accessibility Size") {
    RegistryAspectRatioExamples().dynamicTypeSize(.accessibility3)
}
