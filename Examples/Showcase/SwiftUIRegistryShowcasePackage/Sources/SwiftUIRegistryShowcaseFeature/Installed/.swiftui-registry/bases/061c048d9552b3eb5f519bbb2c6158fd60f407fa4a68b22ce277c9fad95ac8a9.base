import Foundation
import SwiftUI
import SwiftUIRegistryFoundations

/// A source-owned nutrition progress row with prepared display values.
public struct MacroProgress: View {
    @Environment(\.registryTheme) private var theme

    private let name: LocalizedStringResource
    private let value: Text
    private let target: Text
    private let progress: Double
    private let systemImage: String
    private let tint: Color

    public init(
        _ name: LocalizedStringResource,
        value: Text,
        target: Text,
        progress: Double,
        systemImage: String,
        tint: Color
    ) {
        self.name = name
        self.value = value
        self.target = target
        self.progress = progress
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.compactSpacing) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: theme.metrics.compactSpacing) {
                    Label(name, systemImage: systemImage)
                        .font(.headline)
                    Spacer(minLength: theme.metrics.standardSpacing)
                    MacroValue(value: value, target: target)
                }

                VStack(alignment: .leading, spacing: theme.metrics.compactSpacing) {
                    Label(name, systemImage: systemImage)
                        .font(.headline)
                    MacroValue(value: value, target: target)
                }
            }

            ProgressView(value: min(max(progress, 0), 1))
                .tint(tint)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MacroValue: View {
    let value: Text
    let target: Text

    var body: some View {
        HStack(spacing: 3) {
            value
                .fontWeight(.semibold)
            Text("of")
                .foregroundStyle(.secondary)
            target
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}

#Preview("Macro Progress") {
    MacroProgress(
        "Protein",
        value: Text(96, format: .number),
        target: Text(130, format: .number),
        progress: 96.0 / 130.0,
        systemImage: "fish.fill",
        tint: .indigo
    )
    .padding()
}
