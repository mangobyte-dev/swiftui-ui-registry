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
                SurfaceSection(tuning: $tuning)
                RadiusSection(tuning: $tuning)
                SpacingSection(tuning: $tuning)
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

private struct SurfaceSection: View {
    @Binding var tuning: ThemeTuning

    var body: some View {
        Section("Surface") {
            TuningSlider("Surface opacity", value: $tuning.surfaceOpacity, in: 0...0.2, step: 0.005, fraction: 3)
            TuningSlider("Border opacity", value: $tuning.borderOpacity, in: 0...0.3, step: 0.01, fraction: 2)
            TuningSlider("Border width", value: $tuning.borderWidth, in: 0.5...3, step: 0.5, fraction: 1)
            TuningSlider("Emphasized border", value: $tuning.emphasizedBorderWidth, in: 1...4, step: 0.5, fraction: 1)
        }
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
