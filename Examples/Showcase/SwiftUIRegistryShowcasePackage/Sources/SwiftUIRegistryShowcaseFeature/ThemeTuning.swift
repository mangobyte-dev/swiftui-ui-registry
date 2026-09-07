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

        /// Every accent a swatch can show; the custom color has its own picker.
        static let named: [Accent] = allCases.filter { $0 != .custom }

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

        func color(custom: RGB, dark: RGB? = nil) -> Color? {
            switch self {
            // The app accent rather than nil: registryTheme(_:) can only apply
            // the tint conditionally, so a theme that flips between nil and a
            // value replaces the whole subtree and throws the panel off its
            // tab. The export still omits the accent for System.
            case .system: Color.accentColor
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
            case .custom:
                if let dark {
                    Color(uiColor: UIColor { traits in
                        traits.userInterfaceStyle == .dark ? dark.uiColor : custom.uiColor
                    })
                } else {
                    custom.color
                }
            }
        }
    }

    struct RGB: Codable, Equatable {
        var red: Double
        var green: Double
        var blue: Double

        var color: Color { Color(red: red, green: green, blue: blue) }
        var uiColor: UIColor { UIColor(red: red, green: green, blue: blue, alpha: 1) }

        var source: String {
            "Color(red: \(RGB.format(red)), green: \(RGB.format(green)), blue: \(RGB.format(blue)))"
        }

        var uiSource: String {
            "UIColor(red: \(RGB.format(red)), green: \(RGB.format(green)), blue: \(RGB.format(blue)), alpha: 1)"
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

    /// The font design the theme carries, applied by `registryTheme(_:)` through
    /// `fontDesign(_:)`. A custom family is never a knob: it lives in the Swift
    /// export and the theme package, not in a code.
    enum FontDesign: String, Codable, CaseIterable, Identifiable {
        case `default`, rounded, serif, monospaced
        var id: String { rawValue }
        var title: String {
            switch self {
            case .default: "Default"
            case .rounded: "Rounded"
            case .serif: "Serif"
            case .monospaced: "Mono"
            }
        }

        /// The SwiftUI design; `nil` keeps the system font.
        var design: Font.Design? {
            switch self {
            case .default: nil
            case .rounded: .rounded
            case .serif: .serif
            case .monospaced: .monospaced
            }
        }

        /// The `fontDesign(_:)` argument for the export, or `nil` for the default.
        var source: String? {
            switch self {
            case .default: nil
            case .rounded: ".rounded"
            case .serif: ".serif"
            case .monospaced: ".monospaced"
            }
        }
    }

    /// Which colors the chart draws, kept separate from the accent so a chart
    /// can leave the accent alone. `reserved` (index 3) has no case here, so a
    /// code carrying it is rejected rather than guessed.
    enum ChartPalette: String, Codable, CaseIterable, Identifiable {
        case accent, spectrum, monochrome
        var id: String { rawValue }
        var title: String {
            switch self {
            case .accent: "Accent"
            case .spectrum: "Spectrum"
            case .monochrome: "Mono"
            }
        }

        var registryPalette: RegistryTheme.ChartPalette {
            switch self {
            case .accent: .accent
            case .spectrum: .spectrum
            case .monochrome: .monochrome
            }
        }
    }

    /// A named bundle of the spacing, padding, and radius metrics. Not a stored
    /// field or part of a code: selecting one writes those seven knobs, and the
    /// panel shows which bundle the current knobs match, or Custom.
    enum Density: String, CaseIterable, Identifiable {
        case compact, regular, generous
        var id: String { rawValue }
        var title: String { rawValue.capitalized }
    }

    var accent: Accent = .indigo
    var customAccent = RGB(red: 0.35, green: 0.34, blue: 0.84)
    /// A separate custom accent for dark appearance; `nil` reuses `customAccent`.
    var customAccentDark: RGB? = nil
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
    var fontDesign: FontDesign = .default
    var surfaceStep = 0.02
    var chartPalette: ChartPalette = .accent
    /// Background, foreground, and secondary foreground as optional custom light
    /// and dark pairs; `nil` leaves the system color in place. The dark value is
    /// `nil` unless the pair carries its own dark color.
    var background: RGB? = nil
    var backgroundDark: RGB? = nil
    var foreground: RGB? = nil
    var foregroundDark: RGB? = nil
    var secondaryForeground: RGB? = nil
    var secondaryForegroundDark: RGB? = nil
    var appearance: Appearance = .system
    var textSize: TextSize = .system
    var rightToLeft = false

    static let `default` = ThemeTuning()

    // MARK: Projections for the panel's controls

    /// The custom accent as a color; setting it also selects the custom accent.
    var customAccentColor: Color {
        get { customAccent.color }
        set {
            customAccent = RGB(newValue)
            accent = .custom
        }
    }

    /// Whether dark appearance uses its own custom accent.
    var hasSeparateDarkAccent: Bool {
        get { customAccentDark != nil }
        set {
            customAccentDark = newValue ? customAccent : nil
            if newValue { accent = .custom }
        }
    }

    /// The dark custom accent as a color; setting it also selects the custom accent.
    var customAccentDarkColor: Color {
        get { (customAccentDark ?? customAccent).color }
        set {
            customAccentDark = RGB(newValue)
            accent = .custom
        }
    }

    // MARK: Color pair projections for the panel's controls

    /// The seed a pair takes when its switch is turned on, before the picker
    /// touches it: the system background for the surface, the label for the
    /// text, a lighter step for the secondary text.
    private static let backgroundSeed = RGB(red: 1, green: 1, blue: 1)
    private static let foregroundSeed = RGB(red: 0, green: 0, blue: 0)
    private static let secondaryForegroundSeed = RGB(red: 0.24, green: 0.24, blue: 0.26)

    var hasBackground: Bool {
        get { background != nil }
        set {
            background = newValue ? (background ?? Self.backgroundSeed) : nil
            if !newValue { backgroundDark = nil }
        }
    }
    var backgroundColor: Color {
        get { (background ?? Self.backgroundSeed).color }
        set { background = RGB(newValue) }
    }
    var hasBackgroundDark: Bool {
        get { backgroundDark != nil }
        set { backgroundDark = newValue ? (backgroundDark ?? background ?? Self.backgroundSeed) : nil }
    }
    var backgroundDarkColor: Color {
        get { (backgroundDark ?? background ?? Self.backgroundSeed).color }
        set { backgroundDark = RGB(newValue) }
    }

    var hasForeground: Bool {
        get { foreground != nil }
        set {
            foreground = newValue ? (foreground ?? Self.foregroundSeed) : nil
            if !newValue { foregroundDark = nil }
        }
    }
    var foregroundColor: Color {
        get { (foreground ?? Self.foregroundSeed).color }
        set { foreground = RGB(newValue) }
    }
    var hasForegroundDark: Bool {
        get { foregroundDark != nil }
        set { foregroundDark = newValue ? (foregroundDark ?? foreground ?? Self.foregroundSeed) : nil }
    }
    var foregroundDarkColor: Color {
        get { (foregroundDark ?? foreground ?? Self.foregroundSeed).color }
        set { foregroundDark = RGB(newValue) }
    }

    var hasSecondaryForeground: Bool {
        get { secondaryForeground != nil }
        set {
            secondaryForeground = newValue ? (secondaryForeground ?? Self.secondaryForegroundSeed) : nil
            if !newValue { secondaryForegroundDark = nil }
        }
    }
    var secondaryForegroundColor: Color {
        get { (secondaryForeground ?? Self.secondaryForegroundSeed).color }
        set { secondaryForeground = RGB(newValue) }
    }
    var hasSecondaryForegroundDark: Bool {
        get { secondaryForegroundDark != nil }
        set { secondaryForegroundDark = newValue ? (secondaryForegroundDark ?? secondaryForeground ?? Self.secondaryForegroundSeed) : nil }
    }
    var secondaryForegroundDarkColor: Color {
        get { (secondaryForegroundDark ?? secondaryForeground ?? Self.secondaryForegroundSeed).color }
        set { secondaryForegroundDark = RGB(newValue) }
    }

    // MARK: Derived

    var theme: RegistryTheme {
        var theme = RegistryTheme(
            accent: accent.color(custom: customAccent, dark: customAccentDark),
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
        theme.fontDesign = fontDesign.design
        theme.surfaceOpacity = surfaceOpacity
        theme.surfaceStep = surfaceStep
        theme.chartPalette = chartPalette.registryPalette
        theme.background = Self.dynamicColor(background, dark: backgroundDark)
        theme.foreground = Self.dynamicColor(foreground, dark: foregroundDark)
        theme.secondaryForeground = Self.dynamicColor(secondaryForeground, dark: secondaryForegroundDark)
        return theme
    }

    /// A single color from a light value and an optional dark value, matching
    /// the accent's dual-appearance shape; `nil` when the light value is absent.
    private static func dynamicColor(_ light: RGB?, dark: RGB?) -> Color? {
        guard let light else { return nil }
        guard let dark else { return light.color }
        return Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark.uiColor : light.uiColor
        })
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
        if accent == .custom, let dark = customAccentDark {
            lines.append("    accent: Color(uiColor: UIColor { traits in")
            lines.append("        traits.userInterfaceStyle == .dark")
            lines.append("            ? \(dark.uiSource)")
            lines.append("            : \(customAccent.uiSource)")
            lines.append("    }),")
        } else if accent == .custom {
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
        let extras = newFieldExports
        if !extras.isEmpty {
            lines[0] = "var theme = RegistryTheme("
            lines += extras
        }
        lines.append("")
        lines.append("// Apply once at the root of your scene; every registry item below inherits it.")
        lines.append("ContentView()")
        lines.append("    .registryTheme(theme)")
        return lines.joined(separator: "\n")
    }

    /// The lines the export appends for version-b fields that are off their
    /// default, so an unchanged tuning still exports the version-a initializer.
    private var newFieldExports: [String] {
        var lines: [String] = []
        if let design = fontDesign.source {
            lines.append("theme.fontDesign = \(design)")
        }
        if surfaceStep != Self.default.surfaceStep {
            lines.append("theme.surfaceStep = \(RGB.format(surfaceStep))")
        }
        if chartPalette != .accent {
            lines.append("theme.chartPalette = .\(chartPalette.rawValue)")
        }
        lines += colorPairExport("theme.background", light: background, dark: backgroundDark)
        lines += colorPairExport("theme.foreground", light: foreground, dark: foregroundDark)
        lines += colorPairExport(
            "theme.secondaryForeground", light: secondaryForeground, dark: secondaryForegroundDark
        )
        return lines
    }

    private func colorPairExport(_ property: String, light: RGB?, dark: RGB?) -> [String] {
        guard let light else { return [] }
        guard let dark else { return ["\(property) = \(light.source)"] }
        return [
            "\(property) = Color(uiColor: UIColor { traits in",
            "    traits.userInterfaceStyle == .dark",
            "        ? \(dark.uiSource)",
            "        : \(light.uiSource)",
            "})",
        ]
    }

    private static func points(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }

    // MARK: Import

    /// Reads a preset code, with or without its `--preset` flag, or a
    /// `RegistryTheme(...)` initializer in the exact shape ``swiftSource`` writes
    /// or any subset of its labeled arguments, into the knobs. Unknown or
    /// malformed arguments are ignored; nothing is imported when neither a code
    /// nor a `RegistryTheme(` call is present. Environment switches are never
    /// part of a theme.
    static func parse(_ swift: String, into base: ThemeTuning = .default) -> ThemeTuning? {
        if let code = presetCode(in: swift) {
            return ThemeTuning(presetCode: code, base: base)
        }
        guard swift.contains("RegistryTheme(") else { return nil }
        var tuning = base
        let text = swift.replacingOccurrences(of: "\n", with: " ")

        func number(_ label: String) -> Double? {
            guard let range = text.range(of: "\\b\(label):\\s*([0-9]+(?:\\.[0-9]+)?)", options: .regularExpression) else {
                return nil
            }
            let match = text[range]
            let digits = match.split(separator: ":").last.map { $0.trimmingCharacters(in: .whitespaces) } ?? ""
            return Double(digits)
        }

        func opacity(_ label: String) -> Double? {
            guard let range = text.range(of: "\(label):\\s*\\.primary\\.opacity\\(([0-9.]+)\\)", options: .regularExpression) else {
                return nil
            }
            let match = text[range]
            guard let open = match.lastIndex(of: "("), let close = match.lastIndex(of: ")") else { return nil }
            return Double(match[match.index(after: open)..<close])
        }

        func rgb(after anchor: String) -> RGB? {
            guard let anchorRange = text.range(of: anchor) else { return nil }
            let tail = text[anchorRange.upperBound...]
            guard let range = tail.range(of: "(?:UI)?Color\\(red:\\s*([0-9.]+),\\s*green:\\s*([0-9.]+),\\s*blue:\\s*([0-9.]+)", options: .regularExpression) else {
                return nil
            }
            let parts = tail[range].split(separator: ",").compactMap { part -> Double? in
                Double(part.split(separator: ":").last?.trimmingCharacters(in: .whitespaces) ?? "")
            }
            guard parts.count == 3 else { return nil }
            return RGB(red: parts[0], green: parts[1], blue: parts[2])
        }

        let colors = text.matches(of: #/(?:UI)?Color\(red:\s*([0-9.]+),\s*green:\s*([0-9.]+),\s*blue:\s*([0-9.]+)/#).compactMap { match -> RGB? in
            guard let red = Double(match.1), let green = Double(match.2), let blue = Double(match.3) else { return nil }
            return RGB(red: red, green: green, blue: blue)
        }
        if text.contains("accent: Color(uiColor: UIColor {"), colors.count >= 2 {
            // The dual form lists the dark color after `?`, then the light one after `:`.
            tuning.accent = .custom
            tuning.customAccentDark = colors[0]
            tuning.customAccent = colors[1]
        } else if let range = text.range(of: "accent:\\s*\\.([a-z]+)", options: .regularExpression) {
            let word = text[range].split(separator: ".").last.map(String.init) ?? ""
            let presetNames: [String: Accent] = ["primary": .ink, "rose": .pink, "emerald": .green, "amber": .yellow, "graphite": .ink, "system": .system]
            if let known = presetNames[word] {
                tuning.accent = known
            } else if let named = Accent(rawValue: word) {
                tuning.accent = named
            }
            tuning.customAccentDark = nil
        } else if let custom = rgb(after: "accent:") {
            tuning.accent = .custom
            tuning.customAccent = custom
            tuning.customAccentDark = nil
        }

        if text.contains("onAccent: .black") {
            tuning.darkLabelOnAccent = true
        } else if text.contains("onAccent: .white") {
            tuning.darkLabelOnAccent = false
        }
        if let value = opacity("surface") { tuning.surfaceOpacity = value }
        if let value = opacity("border") { tuning.borderOpacity = value }
        if let value = number("disabledOpacity") { tuning.disabledOpacity = value }
        if let value = number("compactSpacing") { tuning.compactSpacing = value }
        if let value = number("standardSpacing") { tuning.standardSpacing = value }
        if let value = number("sectionSpacing") { tuning.sectionSpacing = value }
        if let value = number("controlHorizontalPadding") { tuning.controlHorizontalPadding = value }
        if let value = number("borderWidth") { tuning.borderWidth = value }
        if let value = number("emphasizedBorderWidth") { tuning.emphasizedBorderWidth = value }
        if let value = number("compactRadius") { tuning.compactRadius = value }
        if let value = number("controlRadius") { tuning.controlRadius = value }
        if let value = number("cardRadius") { tuning.cardRadius = value }
        return tuning
    }

    // MARK: Density

    /// The seven metrics a density bundle sets. Density is derived, never stored:
    /// selecting a bundle writes these knobs, and `matchingDensity` reports which
    /// bundle, if any, the current knobs match.
    private struct DensityMetrics {
        let compactSpacing, standardSpacing, sectionSpacing, controlHorizontalPadding: Double
        let compactRadius, controlRadius, cardRadius: Double
    }

    private static let densityBundles: [Density: DensityMetrics] = [
        .compact: DensityMetrics(
            compactSpacing: 6, standardSpacing: 12, sectionSpacing: 20, controlHorizontalPadding: 10,
            compactRadius: 4, controlRadius: 6, cardRadius: 12
        ),
        .regular: DensityMetrics(
            compactSpacing: 8, standardSpacing: 16, sectionSpacing: 24, controlHorizontalPadding: 12,
            compactRadius: 6, controlRadius: 8, cardRadius: 16
        ),
        .generous: DensityMetrics(
            compactSpacing: 8, standardSpacing: 16, sectionSpacing: 28, controlHorizontalPadding: 16,
            compactRadius: 10, controlRadius: 14, cardRadius: 24
        ),
    ]

    /// Writes a density bundle's seven metrics, leaving every other knob alone.
    mutating func apply(density: Density) {
        guard let bundle = Self.densityBundles[density] else { return }
        compactSpacing = bundle.compactSpacing
        standardSpacing = bundle.standardSpacing
        sectionSpacing = bundle.sectionSpacing
        controlHorizontalPadding = bundle.controlHorizontalPadding
        compactRadius = bundle.compactRadius
        controlRadius = bundle.controlRadius
        cardRadius = bundle.cardRadius
    }

    /// The bundle the spacing, padding, and radius knobs currently match, or
    /// `nil` when they match none, in which case the panel shows Custom.
    var matchingDensity: Density? {
        Density.allCases.first { density in
            guard let bundle = Self.densityBundles[density] else { return false }
            return compactSpacing == bundle.compactSpacing
                && standardSpacing == bundle.standardSpacing
                && sectionSpacing == bundle.sectionSpacing
                && controlHorizontalPadding == bundle.controlHorizontalPadding
                && compactRadius == bundle.compactRadius
                && controlRadius == bundle.controlRadius
                && cardRadius == bundle.cardRadius
        }
    }

    // MARK: Presets

    /// Loads a foundation preset's accent choice into the knobs, keeping the
    /// tuned metrics. MANGO is the exception: its strokeless surface and
    /// generous radii are part of its identity, so its case decodes the whole
    /// tuning from its preset code, keeping only the environment switches.
    mutating func apply(presetNamed name: String) {
        switch name {
        case "System": accent = .system; darkLabelOnAccent = false
        case "Graphite": accent = .ink; darkLabelOnAccent = false
        case "Indigo": accent = .indigo; darkLabelOnAccent = false
        case "Rose": accent = .pink; darkLabelOnAccent = false
        case "Emerald": accent = .green; darkLabelOnAccent = false
        case "Amber": accent = .yellow; darkLabelOnAccent = true
        case "Mango":
            // MANGO carries its own metrics, not only an accent, so decode its
            // pinned preset code (Registry/preset_vectors.json) over self to
            // load every knob while keeping the environment switches.
            if let mango = ThemeTuning(presetCode: "a74hGF01CVunaG0vzZJG", base: self) {
                self = mango
            }
        default: break
        }
    }

    // MARK: Persistence

    private static let storageKey = "showcase.tuning"

    /// The knobs a catalog launch starts from: a `-preset` code wins,
    /// `-default-tuning` resets them for the UI suite, and otherwise the last
    /// persisted tuning returns.
    static func initial(for arguments: LaunchArguments) -> ThemeTuning {
        if let code = arguments.value(after: "-preset"), let tuned = ThemeTuning(presetCode: code) {
            return tuned
        }
        return arguments.contains("-default-tuning") ? .default : restored()
    }

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
