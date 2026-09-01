import SwiftUI

/// Demonstrates every installed registry `component` item (not blocks or
/// recipes) using each item's real declared usage snippet.
///
/// Each section is its own `View` for readability. Each is registered
/// against its item's `usage` snippet in `Registry/items/*.json`.
struct ComponentsGallery: View {
    @State private var email = ""
    @State private var notes = ""
    @State private var accepted = false
    @State private var bold = false
    @State private var italic = false
    @State private var registryToggleOn = false
    @State private var currency = "KWD"

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                Text("Components")
                    .font(.largeTitle.bold())

                BadgeSection()
                ButtonSection()
                ButtonGroupSection()
                CardSection()
                CheckboxSection(accepted: $accepted)
                InputSection(email: $email)
                LabelSection()
                MacroProgressSection()
                MetricCardSection()
                ProgressSection()
                SelectSection(currency: $currency)
                SeparatorSection()
                SpinnerSection()
                TextareaSection(notes: $notes)
                ToggleGroupSection(bold: $bold, italic: $italic)
                ToggleSection(isOn: $registryToggleOn)
                TransactionRowSection()
            }
            .padding()
            .containerRelativeFrame(.horizontal) { length, _ in
                min(length, 792)
            }
        }
    }
}

private struct BadgeSection: View {
    var body: some View {
        GroupBox("Badge") {
            HStack(spacing: 12) {
                Text("New").registryBadge()
                Text("Secondary").registryBadge(.secondary)
                Text("Outline").registryBadge(.outline)
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .registryBadge(.positive)
                Text("Needs attention").registryBadge(.destructive)
            }
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct ButtonSection: View {
    var body: some View {
        GroupBox("Button") {
            HStack(spacing: 12) {
                Button("Save changes") {}
                    .buttonStyle(.registry)
                Button("Cancel") {}
                    .buttonStyle(.registryOutline)
                Button("Delete", role: .destructive) {}
                    .buttonStyle(.registry)
            }
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct ButtonGroupSection: View {
    var body: some View {
        GroupBox("Button group") {
            ControlGroup {
                Button("Undo", systemImage: "arrow.uturn.backward") {}
                Button("Redo", systemImage: "arrow.uturn.forward") {}
            }
            .controlGroupStyle(.registryButtons)
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct CardSection: View {
    var body: some View {
        GroupBox {
            Text("Manage billing and renewal details from your account settings.")
        } label: {
            Label("Card", systemImage: "creditcard.fill")
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct CheckboxSection: View {
    @Binding var accepted: Bool

    var body: some View {
        GroupBox("Checkbox") {
            Toggle("Accept terms", isOn: $accepted)
                .toggleStyle(.registryCheckbox)
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct InputSection: View {
    @Binding var email: String

    var body: some View {
        GroupBox("Input") {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Email", text: $email)
                    .textFieldStyle(.registryInput)
                TextField("Email", text: $email)
                    .textFieldStyle(RegistryInputStyle(isInvalid: true))
            }
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct LabelSection: View {
    var body: some View {
        GroupBox("Label") {
            VStack(alignment: .leading, spacing: 12) {
                Label("Account settings", systemImage: "person.crop.circle")
                    .labelStyle(.registry)
                Label("Continue", systemImage: "chevron.forward")
                    .labelStyle(.registryTrailingIcon)
            }
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct MacroProgressSection: View {
    var body: some View {
        GroupBox("Macro progress") {
            MacroProgress(
                "Protein",
                value: Text("96 g"),
                target: Text("130 g"),
                progress: 96.0 / 130.0,
                systemImage: "fish.fill",
                tint: .indigo
            )
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct MetricCardSection: View {
    var body: some View {
        GroupBox("Metric card") {
            MetricCard(
                "Available balance",
                value: Text(12_480.32, format: .currency(code: "USD")),
                detail: Text("Up 8.2% this month"),
                systemImage: "creditcard.fill"
            )
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct ProgressSection: View {
    var body: some View {
        GroupBox("Progress") {
            VStack(alignment: .leading, spacing: 16) {
                ProgressView(value: 0.68) {
                    Text("Uploading")
                } currentValueLabel: {
                    Text("68 percent")
                }
                .progressViewStyle(.registryLinear)

                ProgressView(value: 1) {
                    Text("Import complete")
                }
                .progressViewStyle(.registryLinearPositive)
            }
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct SelectSection: View {
    @Binding var currency: String

    var body: some View {
        GroupBox("Select") {
            Picker("Currency", selection: $currency) {
                Text("Kuwaiti dinar").tag("KWD")
                Text("US dollar").tag("USD")
            }
            .registrySelect()
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct SeparatorSection: View {
    var body: some View {
        GroupBox("Separator") {
            VStack(alignment: .leading, spacing: 12) {
                Divider()
                    .registrySeparator(insets: EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                HStack {
                    Text("Left")
                    Divider()
                        .registrySeparator(.vertical)
                        .frame(height: 24)
                    Text("Right")
                }
            }
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct SpinnerSection: View {
    var body: some View {
        GroupBox("Spinner") {
            ProgressView("Loading results")
                .progressViewStyle(.registrySpinner)
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct TextareaSection: View {
    @Binding var notes: String

    var body: some View {
        GroupBox("Textarea") {
            TextEditor(text: $notes)
                .registryTextArea(accessibilityLabel: Text("Delivery instructions"))
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct ToggleGroupSection: View {
    @Binding var bold: Bool
    @Binding var italic: Bool

    var body: some View {
        GroupBox("Toggle group") {
            ControlGroup {
                Toggle("Bold", systemImage: "bold", isOn: $bold)
                Toggle("Italic", systemImage: "italic", isOn: $italic)
            }
            .registryToggleGroup()
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct ToggleSection: View {
    @Binding var isOn: Bool

    var body: some View {
        GroupBox("Toggle") {
            Toggle("Bold", systemImage: "bold", isOn: $isOn)
                .toggleStyle(.registryToggle)
        }
        .groupBoxStyle(.registryCard)
    }
}

private struct TransactionRowSection: View {
    var body: some View {
        GroupBox("Transaction row") {
            TransactionRow(
                title: Text("Mishmash Bakery"),
                subtitle: Text("Today, 09:41"),
                amount: Text(-8.75, format: .currency(code: "KWD")),
                systemImage: "cup.and.saucer.fill",
                tone: .negative
            )
        }
        .groupBoxStyle(.registryCard)
    }
}

#Preview("Components Gallery") {
    ComponentsGallery()
        .tint(.indigo)
}

#Preview("Components Gallery Dark RTL") {
    ComponentsGallery()
        .tint(.indigo)
        .preferredColorScheme(.dark)
        .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Components Gallery Accessibility Size") {
    ComponentsGallery()
        .tint(.indigo)
        .dynamicTypeSize(.accessibility3)
}
