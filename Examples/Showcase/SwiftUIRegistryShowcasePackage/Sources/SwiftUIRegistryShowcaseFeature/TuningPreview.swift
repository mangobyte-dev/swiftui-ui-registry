import SwiftUI
import SwiftUIRegistryFoundations

/// A representative composition that every token touches. The capture route
/// renders it as `theme-preview` for the website's preset images and for
/// `capture_previews.py --preset`.
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
