import Foundation
import SwiftUI
import SwiftUIRegistryFoundations
import UIKit

/// Every knob the tuning panel exposes, as plain values so the result can be
/// persisted, restored, and exported as the exact `RegistryTheme` source a
/// consuming app pastes once at its root.
struct ThemeTuning: Codable, Equatable {
    enum Accent: String, Codable, CaseIterable, Identifiable {
        case system, ink, blue, indigo, purple, pink, red, orange, yellow, green, mint, teal, cyan, brown, custom

        var id: String { rawValue }

        var title: String {
            switch self {
            case .system: "System"
            case .ink: "Ink"
            case .custom: "Custom"
            default: rawValue.capitalized
            }
        }

        /// The Swift expression that produces this accent, or `nil` for the app tint.
        var source: String? {
            switch self {
            case .system: nil
            case .ink: ".primary"
            case .custom: nil
            default: ".\(rawValue)"
            }
        }

        func color(custom: RGB) -> Color? {
            switch self {
            case .system: nil
            case .ink: .primary
            case .blue: .blue
            case .indigo: .indigo
            case .purple: .purple
            case .pink: .pink
            case .red: .red
            case .orange: .orange
            case .yellow: .yellow
            case .green: .green
            case .mint: .mint
            case .teal: .teal
            case .cyan: .cyan
            case .brown: .brown
            case .custom: custom.color
            }
        }
    }

    struct RGB: Codable, Equatable {
        var red: Double
        var green: Double
        var blue: Double

        var color: Color { Color(red: red, green: green, blue: blue) }

        var source: String {
            "Color(red: \(RGB.format(red)), green: \(RGB.format(green)), blue: \(RGB.format(blue)))"
        }

        static func format(_ value: Double) -> String {
            String(format: "%.3f", value)
        }

        init(red: Double, green: Double, blue: Double) {
            self.red = red
            self.green = green
            self.blue = blue
        }

        init(_ color: Color) {
            let resolved = color.resolve(in: EnvironmentValues())
            red = Double(resolved.red)
            green = Double(resolved.green)
            blue = Double(resolved.blue)
        }
    }

    enum Appearance: String, Codable, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }
        var title: String { rawValue.capitalized }
    }

    enum TextSize: String, Codable, CaseIterable, Identifiable {
        case system, large, accessibility
        var id: String { rawValue }
        var title: String {
            switch self {
            case .system: "System"
            case .large: "Large"
            case .accessibility: "Accessibility"
            }
        }
    }

    var accent: Accent = .indigo
    var customAccent = RGB(red: 0.35, green: 0.34, blue: 0.84)
    var darkLabelOnAccent = false
    var surfaceOpacity = 0.055
    var borderOpacity = 0.08
    var borderWidth = 1.0
    var emphasizedBorderWidth = 2.0
    var compactRadius = 6.0
    var controlRadius = 8.0
    var cardRadius = 16.0
    var compactSpacing = 8.0
    var standardSpacing = 16.0
    var sectionSpacing = 24.0
    var controlHorizontalPadding = 12.0
    var disabledOpacity = 0.5
    var appearance: Appearance = .system
    var textSize: TextSize = .system
    var rightToLeft = false

    static let `default` = ThemeTuning()

    // MARK: Derived

    var theme: RegistryTheme {
        RegistryTheme(
            accent: accent.color(custom: customAccent),
            onAccent: onAccent,
            surface: .primary.opacity(surfaceOpacity),
            border: .primary.opacity(borderOpacity),
            disabledOpacity: disabledOpacity,
            metrics: RegistryMetrics(
                compactSpacing: compactSpacing,
                standardSpacing: standardSpacing,
                sectionSpacing: sectionSpacing,
                controlHorizontalPadding: controlHorizontalPadding,
                borderWidth: borderWidth,
                emphasizedBorderWidth: emphasizedBorderWidth,
                compactRadius: compactRadius,
                controlRadius: controlRadius,
                cardRadius: cardRadius
            )
        )
    }

    private var onAccent: Color {
        if accent == .ink { return Color(uiColor: .systemBackground) }
        return darkLabelOnAccent ? .black : .white
    }

    private var onAccentSource: String {
        if accent == .ink { return "Color(uiColor: .systemBackground)" }
        return darkLabelOnAccent ? ".black" : ".white"
    }

    var preferredColorScheme: ColorScheme? {
        switch appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var dynamicTypeSize: DynamicTypeSize? {
        switch textSize {
        case .system: nil
        case .large: .xxxLarge
        case .accessibility: .accessibility3
        }
    }

    /// The exact Swift a consumer pastes; applying it at the root reproduces
    /// what the panel shows.
    var swiftSource: String {
        var lines = ["let theme = RegistryTheme("]
        if accent == .custom {
            lines.append("    accent: \(customAccent.source),")
        } else if let source = accent.source {
            lines.append("    accent: \(source),")
        }
        lines.append("    onAccent: \(onAccentSource),")
        lines.append("    surface: .primary.opacity(\(RGB.format(surfaceOpacity))),")
        lines.append("    border: .primary.opacity(\(RGB.format(borderOpacity))),")
        lines.append("    disabledOpacity: \(RGB.format(disabledOpacity)),")
        lines.append("    metrics: RegistryMetrics(")
        lines.append("        compactSpacing: \(Self.points(compactSpacing)),")
        lines.append("        standardSpacing: \(Self.points(standardSpacing)),")
        lines.append("        sectionSpacing: \(Self.points(sectionSpacing)),")
        lines.append("        controlHorizontalPadding: \(Self.points(controlHorizontalPadding)),")
        lines.append("        borderWidth: \(Self.points(borderWidth)),")
        lines.append("        emphasizedBorderWidth: \(Self.points(emphasizedBorderWidth)),")
        lines.append("        compactRadius: \(Self.points(compactRadius)),")
        lines.append("        controlRadius: \(Self.points(controlRadius)),")
        lines.append("        cardRadius: \(Self.points(cardRadius))")
        lines.append("    )")
        lines.append(")")
        lines.append("")
        lines.append("// Apply once at the root of your scene; every registry item below inherits it.")
        lines.append("ContentView()")
        lines.append("    .registryTheme(theme)")
        return lines.joined(separator: "\n")
    }

    private static func points(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }

    // MARK: Presets

    /// Loads a foundation preset's accent choice into the knobs, keeping the
    /// tuned metrics.
    mutating func apply(presetNamed name: String) {
        switch name {
        case "System": accent = .system; darkLabelOnAccent = false
        case "Graphite": accent = .ink; darkLabelOnAccent = false
        case "Indigo": accent = .indigo; darkLabelOnAccent = false
        case "Rose": accent = .pink; darkLabelOnAccent = false
        case "Emerald": accent = .green; darkLabelOnAccent = false
        case "Amber": accent = .yellow; darkLabelOnAccent = true
        default: break
        }
    }

    // MARK: Persistence

    private static let storageKey = "showcase.tuning"

    static func restored() -> ThemeTuning {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let tuning = try? JSONDecoder().decode(ThemeTuning.self, from: data) else {
            return .default
        }
        return tuning
    }

    func persist() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
