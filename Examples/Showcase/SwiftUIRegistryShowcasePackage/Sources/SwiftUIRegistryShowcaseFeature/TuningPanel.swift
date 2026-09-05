import SwiftUI
import SwiftUIRegistryFoundations
import UIKit

/// The theme tuning panel: every foundation token as a live control beside a
/// preview of the registry, with the exact Swift to paste once at an app root.
/// Side by side on a regular width; stacked with the preview first on iPhone.
struct TuningPanel: View {
    @Binding var tuning: ThemeTuning
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var didCopy = false
    @State private var isShowingSwift = false
    @State private var isImporting = false
    @State private var importText = ""
    @State private var importFailed = false

    var body: some View {
        NavigationStack {
            Group {
                if sizeClass == .regular {
                    HStack(spacing: 0) {
                        controls
                            .frame(maxWidth: 420)
                        Divider()
                        ScrollView {
                            TuningPreview()
                                .padding()
                        }
                    }
                } else {
                    controls
                }
            }
            .navigationTitle("Tune")
            .sheet(isPresented: $isImporting) {
                ImportThemeSheet(text: $importText, failed: $importFailed) {
                    if let parsed = ThemeTuning.parse(importText, into: tuning) {
                        withAnimation(.snappy) { tuning = parsed }
                        isImporting = false
                    } else {
                        importFailed = true
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        withAnimation(.snappy) { tuning = .default }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Import", systemImage: "square.and.arrow.down") {
                        importText = ""
                        importFailed = false
                        isImporting = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(didCopy ? "Copied" : "Copy Swift", systemImage: didCopy ? "checkmark" : "doc.on.doc") {
                        UIPasteboard.general.string = tuning.swiftSource
                        didCopy = true
                        Task {
                            try? await Task.sleep(for: .seconds(1.5))
                            didCopy = false
                        }
                    }
                }
            }
        }
    }

    private var controls: some View {
        Form {
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

            Section {
                DisclosureGroup("Swift", isExpanded: $isShowingSwift) {
                    CodeBlock(tuning.swiftSource)
                    Text("Paste this once at your scene root. Every registry item you install inherits it.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if sizeClass != .regular {
                Section("Preview") {
                    TuningPreview()
                        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                }
            }

            Section("Accent") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 8)], spacing: 8) {
                    ForEach(ThemeTuning.Accent.allCases.filter { $0 != .custom }) { accent in
                        AccentSwatch(
                            accent: accent,
                            isSelected: tuning.accent == accent,
                            custom: tuning.customAccent
                        ) {
                            withAnimation(.snappy) { tuning.accent = accent }
                        }
                    }
                }
                .padding(.vertical, 4)

                ColorPicker(
                    "Custom accent",
                    selection: Binding(
                        get: { tuning.customAccent.color },
                        set: { color in
                            tuning.customAccent = ThemeTuning.RGB(color)
                            tuning.accent = .custom
                        }
                    ),
                    supportsOpacity: false
                )
                Toggle(
                    "Separate dark accent",
                    isOn: Binding(
                        get: { tuning.customAccentDark != nil },
                        set: { enabled in
                            tuning.customAccentDark = enabled ? tuning.customAccent : nil
                            if enabled { tuning.accent = .custom }
                        }
                    )
                )
                if let dark = tuning.customAccentDark {
                    ColorPicker(
                        "Custom accent in dark",
                        selection: Binding(
                            get: { dark.color },
                            set: { color in
                                tuning.customAccentDark = ThemeTuning.RGB(color)
                                tuning.accent = .custom
                            }
                        ),
                        supportsOpacity: false
                    )
                }
                Toggle("Dark label on accent", isOn: $tuning.darkLabelOnAccent)
                    .disabled(tuning.accent == .ink)
            }

            Section("Surface") {
                TuningSlider("Surface opacity", value: $tuning.surfaceOpacity, in: 0...0.2, step: 0.005, fraction: 3)
                TuningSlider("Border opacity", value: $tuning.borderOpacity, in: 0...0.3, step: 0.01, fraction: 2)
                TuningSlider("Border width", value: $tuning.borderWidth, in: 0.5...3, step: 0.5, fraction: 1)
                TuningSlider("Emphasized border", value: $tuning.emphasizedBorderWidth, in: 1...4, step: 0.5, fraction: 1)
            }

            Section("Radius") {
                TuningSlider("Compact", value: $tuning.compactRadius, in: 0...12, step: 1)
                TuningSlider("Control", value: $tuning.controlRadius, in: 0...22, step: 1)
                TuningSlider("Card", value: $tuning.cardRadius, in: 0...32, step: 1)
            }

            Section("Spacing") {
                TuningSlider("Compact", value: $tuning.compactSpacing, in: 4...16, step: 1)
                TuningSlider("Standard", value: $tuning.standardSpacing, in: 8...32, step: 1)
                TuningSlider("Section", value: $tuning.sectionSpacing, in: 12...48, step: 1)
                TuningSlider("Control padding", value: $tuning.controlHorizontalPadding, in: 8...24, step: 1)
            }

            Section("State") {
                TuningSlider("Disabled opacity", value: $tuning.disabledOpacity, in: 0.2...0.8, step: 0.05, fraction: 2)
            }

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
}

/// Paste a `RegistryTheme(...)` initializer, the shape Copy Swift produces, to
/// load it into the knobs. Typing into the editor is a keyboard paste, which
/// never raises the system pasteboard prompt.
private struct ImportThemeSheet: View {
    @Binding var text: String
    @Binding var failed: Bool
    let apply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Paste a RegistryTheme initializer. Every labeled argument it carries replaces the matching knob; the rest keep their values.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextEditor(text: $text)
                    .registryTextArea(accessibilityLabel: Text("Theme Swift"), isInvalid: failed, minimumHeight: 240)
                    .font(.footnote.monospaced())
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if failed {
                    Text("No RegistryTheme( initializer found in the pasted text.")
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

private struct AccentSwatch: View {
    let accent: ThemeTuning.Accent
    let isSelected: Bool
    let custom: ThemeTuning.RGB
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(accent.color(custom: custom) ?? Color.accentColor)
                if accent == .system {
                    Image(systemName: "iphone")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
                if isSelected {
                    Circle()
                        .strokeBorder(.primary, lineWidth: 2)
                        .padding(-3)
                }
            }
            .frame(width: 36, height: 36)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accent.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
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

/// A representative composition that every token touches, so a slider move
/// is visible immediately.
struct TuningPreview: View {
    @Environment(\.registryTheme) private var theme
    @State private var email = ""
    @State private var accepted = true
    @State private var alerts = true
    @State private var plan = "pro"

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.standardSpacing) {
            DemoRow {
                Button("Primary") {}
                    .buttonStyle(.registry)
                Button("Secondary") {}
                    .buttonStyle(.registrySecondary)
            }
            DemoRow {
                Button("Outline") {}
                    .buttonStyle(.registryOutline)
                Button("Ghost") {}
                    .buttonStyle(.registryGhost)
                Button("Delete", role: .destructive) {}
                    .buttonStyle(.registry)
            }

            DemoRow {
                Text("New").registryBadge()
                Text("Draft").registryBadge(.secondary)
                Text("Paid").registryBadge(.positive)
                Text("Overdue").registryBadge(.destructive)
            }

            TextField("Email", text: $email)
                .textFieldStyle(.registryInput)
                .accessibilityLabel("Email")

            GroupBox {
                VStack(alignment: .leading, spacing: theme.metrics.compactSpacing) {
                    Toggle("Accept terms", isOn: $accepted)
                        .toggleStyle(.registryCheckbox)
                    Toggle("Transaction alerts", isOn: $alerts)
                        .toggleStyle(.switch)
                    Picker("Plan", selection: $plan) {
                        Text("Basic").tag("basic")
                        Text("Pro").tag("pro")
                    }
                    .registrySelect()
                }
            } label: {
                Label("Account", systemImage: "person.crop.circle")
            }
            .groupBoxStyle(.registryCard)

            MetricCard(
                "Available balance",
                value: Text(12_480.32, format: .currency(code: "USD")),
                detail: Text("Up 8.2% this month"),
                systemImage: "creditcard.fill"
            )

            InlineAlert(
                "Card delivery delayed",
                message: Text("Your new card now arrives on Thursday.")
            )

            ProgressView(value: 0.68) {
                Text("Uploading")
            }
            .progressViewStyle(.registryLinear)
        }
    }
}

#Preview("Tuning Panel") {
    @Previewable @State var tuning = ThemeTuning.default
    TuningPanel(tuning: $tuning)
        .registryTheme(tuning.theme)
}
