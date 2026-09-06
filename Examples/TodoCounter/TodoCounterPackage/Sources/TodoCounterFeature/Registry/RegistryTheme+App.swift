import SwiftUI
import SwiftUIRegistryFoundations

// swiftui-registry preset a13GkaOXWwIF
// https://swiftui-registry.mangobytekw.workers.dev/create?preset=a13GkaOXWwIF
// Written by `swiftui-registry preset apply`. Edit freely; `swiftui-registry preset resolve` reads it back into a code.

extension RegistryTheme {
    /// Apply once at the scene root: `ContentView().registryTheme(.app)`.
    static let app = RegistryTheme(
        accent: Color(red: 0.898, green: 0.361, blue: 0.231),
        onAccent: .white,
        surface: .primary.opacity(0.070),
        border: .primary.opacity(0.080),
        disabledOpacity: 0.500,
        metrics: RegistryMetrics(
            compactSpacing: 8,
            standardSpacing: 16,
            sectionSpacing: 24,
            controlHorizontalPadding: 12,
            borderWidth: 1,
            emphasizedBorderWidth: 2,
            compactRadius: 8,
            controlRadius: 12,
            cardRadius: 20
        )
    )
}
