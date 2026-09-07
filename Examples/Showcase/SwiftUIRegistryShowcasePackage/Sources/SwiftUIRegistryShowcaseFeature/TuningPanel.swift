import SwiftUI
import SwiftUIRegistryFoundations

/// The theme tuning panel: every foundation token as a live control, the
/// preset code that names the result, and the exact Swift to paste once at
/// an app root. It stays up beside the catalog, an inspector column on iPad
/// and a sheet the catalog remains interactive under on iPhone, so a change
/// shows on the demo behind it at once.
struct TuningPanel: View {
    @Binding var tuning: ThemeTuning
    @State private var isImporting = false
    @State private var importText = ""
    @State private var importFailed = false

    var body: some View {
        NavigationStack {
            Form {
                PresetsSection(tuning: $tuning)
                ExportSection(tuning: tuning)
                AccentSection(tuning: $tuning)
                TypographySection(tuning: $tuning)
                SurfaceSection(tuning: $tuning)
                ChartSection(tuning: $tuning)
                DensitySection(tuning: $tuning)
                RadiusSection(tuning: $tuning)
                SpacingSection(tuning: $tuning)
                ColorsSection(tuning: $tuning)
                StateSection(tuning: $tuning)
                EnvironmentSection(tuning: $tuning)
            }
            .navigationTitle("Tune")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isImporting) {
                ImportThemeSheet(text: $importText, failed: $importFailed, apply: applyImport)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset", action: reset)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Import", systemImage: "square.and.arrow.down", action: beginImport)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    CopyButton("Copy Swift", text: tuning.swiftSource)
                }
            }
        }
    }

    private func reset() {
        withAnimation(.snappy) { tuning = .default }
    }

    private func beginImport() {
        importText = ""
        importFailed = false
        isImporting = true
    }

    private func applyImport() {
        guard let parsed = ThemeTuning.parse(importText, into: tuning) else {
            importFailed = true
            return
        }
        withAnimation(.snappy) { tuning = parsed }
        isImporting = false
    }
}

private struct PresetsSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Presets") {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(RegistryTheme.presets) { preset in
                        Button(preset.name) {
                            withAnimation(.snappy) { tuning.apply(presetNamed: preset.name) }
                        }
                        .buttonStyle(.registryOutline)
                        .controlSize(.small)
                        .registryTheme(preset.theme)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            // The MANGO sample design system, the worked example of building one
            // on the registry. The panel lives in a NavigationStack, so this pushes.
            NavigationLink("See MANGO") {
                MangoDemo()
            }
            .accessibilityIdentifier("tuning.mango")
        }
    }
}

/// The preset code and the Swift, the two ways the tuned theme leaves the app.
private struct ExportSection: View {
    let tuning: ThemeTuning
    @State private var isShowingSwift = false

    var body: some View {
        Section("Export") {
            LabeledContent {
                CopyButton("Copy Code", text: "--preset \(tuning.presetCode)")
                    .labelStyle(.iconOnly)
            } label: {
                Text("Preset code")
                Text(verbatim: tuning.presetCode)
                    .font(.footnote.monospaced())
                    .textSelection(.enabled)
            }
            DisclosureGroup("Swift", isExpanded: $isShowingSwift) {
                CodeBlock(tuning.swiftSource)
                Text("Paste this once at your scene root. Every registry item you install inherits it.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct AccentSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Accent") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 8)], spacing: 8) {
                ForEach(ThemeTuning.Accent.named) { accent in
                    AccentSwatch(
                        accent: accent,
                        isSelected: tuning.accent == accent,
                        custom: tuning.customAccent,
                        diameter: 36
                    ) {
                        withAnimation(.snappy) { tuning.accent = accent }
                    }
                }
            }
            .padding(.vertical, 4)

            ColorPicker("Custom accent", selection: $tuning.customAccentColor, supportsOpacity: false)
            Toggle("Separate dark accent", isOn: $tuning.hasSeparateDarkAccent)
            if tuning.customAccentDark != nil {
                ColorPicker("Custom accent in dark", selection: $tuning.customAccentDarkColor, supportsOpacity: false)
            }
            Toggle("Dark label on accent", isOn: $tuning.darkLabelOnAccent)
                .disabled(tuning.accent == .ink)
        }
    }
}

private struct TypographySection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Typography") {
            Picker("Font design", selection: $tuning.fontDesign) {
                ForEach(ThemeTuning.FontDesign.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("tuning.fontDesign")
            TypeScalePreview(design: tuning.fontDesign.design)
        }
    }
}

/// Apple's eleven text styles rendered in the chosen design, a read-only scale.
/// No custom point sizes: the styles come from the system, so Dynamic Type keeps
/// scaling them.
private struct TypeScalePreview: View {
    let design: Font.Design?

    private static let styles: [(style: Font.TextStyle, name: String)] = [
        (.largeTitle, "Large Title"), (.title, "Title"), (.title2, "Title 2"),
        (.title3, "Title 3"), (.headline, "Headline"), (.subheadline, "Subheadline"),
        (.body, "Body"), (.callout, "Callout"), (.footnote, "Footnote"),
        (.caption, "Caption"), (.caption2, "Caption 2"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Self.styles, id: \.name) { entry in
                Text(entry.name)
                    .font(.system(entry.style, design: design ?? .default))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .accessibilityIdentifier("tuning.typeScale")
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Type scale, eleven text styles")
    }
}

private struct ChartSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Chart") {
            Picker("Chart palette", selection: $tuning.chartPalette) {
                ForEach(ThemeTuning.ChartPalette.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("tuning.chartPalette")
        }
    }
}

/// Density is a bundle of the spacing, padding, and radius metrics, not a stored
/// field. Selecting one writes those knobs; Custom appears only while the knobs
/// match no bundle.
private struct DensitySection: View {
    @Binding var tuning: ThemeTuning

    private var selection: Binding<ThemeTuning.Density?> {
        Binding(
            get: { tuning.matchingDensity },
            set: { newValue in
                if let newValue {
                    withAnimation(.snappy) { tuning.apply(density: newValue) }
                }
            }
        )
    }

    var body: some View {
        Section("Density") {
            Picker("Density", selection: selection) {
                ForEach(ThemeTuning.Density.allCases) { Text($0.title).tag(Optional($0)) }
                if tuning.matchingDensity == nil {
                    Text("Custom").tag(ThemeTuning.Density?.none)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("tuning.density")
        }
    }
}

private struct ColorsSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Colors") {
            ColorPairRows(
                name: "Background",
                identifier: "background",
                isOn: $tuning.hasBackground,
                color: $tuning.backgroundColor,
                hasDark: $tuning.hasBackgroundDark,
                darkColor: $tuning.backgroundDarkColor
            )
            ColorPairRows(
                name: "Foreground",
                identifier: "foreground",
                isOn: $tuning.hasForeground,
                color: $tuning.foregroundColor,
                hasDark: $tuning.hasForegroundDark,
                darkColor: $tuning.foregroundDarkColor
            )
            ColorPairRows(
                name: "Secondary foreground",
                identifier: "secondaryForeground",
                isOn: $tuning.hasSecondaryForeground,
                color: $tuning.secondaryForegroundColor,
                hasDark: $tuning.hasSecondaryForegroundDark,
                darkColor: $tuning.secondaryForegroundDarkColor
            )
        }
    }
}

/// One optional color pair, built to match the accent's custom pair rows: an on
/// switch, a light color, and an optional separate dark color.
private struct ColorPairRows: View {
    let name: String
    let identifier: String
    @Binding var isOn: Bool
    @Binding var color: Color
    @Binding var hasDark: Bool
    @Binding var darkColor: Color

    var body: some View {
        Toggle(isOn: $isOn.animation(.snappy)) { Text(name) }
            .accessibilityIdentifier("tuning.\(identifier)")
        if isOn {
            ColorPicker(selection: $color, supportsOpacity: false) { Text("\(name) color") }
                .accessibilityIdentifier("tuning.\(identifier)Color")
            Toggle(isOn: $hasDark.animation(.snappy)) { Text("Separate dark \(name.lowercased())") }
                .accessibilityIdentifier("tuning.\(identifier)Dark")
            if hasDark {
                ColorPicker(selection: $darkColor, supportsOpacity: false) { Text("\(name) in dark") }
                    .accessibilityIdentifier("tuning.\(identifier)DarkColor")
            }
        }
    }
}

private struct SurfaceSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Surface") {
            TuningSlider("Surface opacity", value: $tuning.surfaceOpacity, in: 0...0.2, step: 0.005, fraction: 3)
            TuningSlider("Surface step", value: $tuning.surfaceStep, in: 0...0.07, step: 0.01, fraction: 2)
                .accessibilityIdentifier("tuning.surfaceStep")
            SurfaceLadderPreview(opacity: tuning.surfaceOpacity, step: tuning.surfaceStep)
            TuningSlider("Border opacity", value: $tuning.borderOpacity, in: 0...0.3, step: 0.01, fraction: 2)
            TuningSlider("Border width", value: $tuning.borderWidth, in: 0.5...3, step: 0.5, fraction: 1)
            TuningSlider("Emphasized border", value: $tuning.emphasizedBorderWidth, in: 1...4, step: 0.5, fraction: 1)
        }
    }
}

/// The four elevation levels the surface step produces, drawn as swatches: the
/// regular surface opacity, one step below and two below it, and one above,
/// each clamped to a visible range, so the step's effect is legible at a glance.
private struct SurfaceLadderPreview: View {
    let opacity: Double
    let step: Double

    private var levels: [(name: String, opacity: Double)] {
        [("Lowest", opacity - 2 * step), ("Low", opacity - step), ("Regular", opacity), ("High", opacity + step)]
            .map { ($0.0, min(1, max(0, $0.1))) }
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(levels, id: \.name) { level in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.primary.opacity(level.opacity))
                        .frame(height: 40)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(.separator)
                        }
                    Text(level.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Elevation ladder: lowest, low, regular, and high surface levels")
    }
}

private struct RadiusSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Radius") {
            TuningSlider("Compact", value: $tuning.compactRadius, in: 0...12, step: 1)
            TuningSlider("Control", value: $tuning.controlRadius, in: 0...22, step: 1)
            TuningSlider("Card", value: $tuning.cardRadius, in: 0...32, step: 1)
        }
    }
}

private struct SpacingSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Spacing") {
            TuningSlider("Compact", value: $tuning.compactSpacing, in: 4...16, step: 1)
            TuningSlider("Standard", value: $tuning.standardSpacing, in: 8...32, step: 1)
            TuningSlider("Section", value: $tuning.sectionSpacing, in: 12...48, step: 1)
            TuningSlider("Control padding", value: $tuning.controlHorizontalPadding, in: 8...24, step: 1)
        }
    }
}

private struct StateSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("State") {
            TuningSlider("Disabled opacity", value: $tuning.disabledOpacity, in: 0.2...0.8, step: 0.05, fraction: 2)
        }
    }
}

private struct EnvironmentSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Environment") {
            Picker("Appearance", selection: $tuning.appearance) {
                ForEach(ThemeTuning.Appearance.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            Picker("Text size", selection: $tuning.textSize) {
                ForEach(ThemeTuning.TextSize.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            Toggle("Right to left", isOn: $tuning.rightToLeft)
        }
    }
}

/// Paste a preset code, with or without its `--preset` flag, or a
/// `RegistryTheme(...)` initializer in the shape Copy Swift produces, to load
/// it into the knobs. Typing into the editor is a keyboard paste, which never
/// raises the system pasteboard prompt.
private struct ImportThemeSheet: View {
    @Binding var text: String
    @Binding var failed: Bool
    let apply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Paste a preset code or a RegistryTheme initializer. A code replaces every knob; an initializer replaces the knobs it names and the rest keep their values.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextEditor(text: $text)
                    .registryTextArea(accessibilityLabel: Text("Preset code or Swift"), isInvalid: failed, minimumHeight: 240)
                    .font(.footnote.monospaced())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if failed {
                    Text("No preset code or RegistryTheme( initializer found in the pasted text.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Import theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply", action: apply)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private struct TuningSlider: View {
    let title: LocalizedStringResource
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let fraction: Int

    init(
        _ title: LocalizedStringResource,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double,
        fraction: Int = 0
    ) {
        self.title = title
        _value = value
        self.range = range
        self.step = step
        self.fraction = fraction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(value, format: .number.precision(.fractionLength(fraction)))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            .font(.subheadline)
            Slider(value: $value, in: range, step: step) {
                Text(title)
            }
        }
    }
}

#Preview("Tuning Panel") {
    @Previewable @State var tuning = ThemeTuning.default
    TuningPanel(tuning: $tuning)
        .registryTheme(tuning.theme)
}
