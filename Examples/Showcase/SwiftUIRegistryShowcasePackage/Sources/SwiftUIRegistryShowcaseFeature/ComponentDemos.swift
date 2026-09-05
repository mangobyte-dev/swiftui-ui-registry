import SwiftUI
import SwiftUIRegistryFoundations

// Each demo renders the item's real `usage` snippet (plus its other variants)
// against the installed registry source, on the registry surface.

/// A row of controls that stacks when it cannot fit on one line, so button
/// and badge labels never get squeezed.
struct DemoRow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) { content }
            VStack(alignment: .leading, spacing: 12) { content }
        }
    }
}

/// Shared chrome for component demos: a surface with the variants inside.
struct DemoSurface<Content: View>: View {
    @Environment(\.registryTheme) private var theme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.standardSpacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.metrics.standardSpacing)
        .registrySurface()
    }
}

struct BadgeDemo: View {
    var body: some View {
        DemoSurface {
            DemoRow {
                Text("New").registryBadge()
                Text("Secondary").registryBadge(.secondary)
                Text("Outline").registryBadge(.outline)
            }
            DemoRow {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .registryBadge(.positive)
                Text("Needs attention").registryBadge(.destructive)
            }
        }
    }
}

struct ButtonDemo: View {
    var body: some View {
        DemoSurface {
            DemoRow {
                Button("Save changes") {}
                    .buttonStyle(.registry)
                Button("Cancel") {}
                    .buttonStyle(.registryOutline)
                Button("Delete", role: .destructive) {}
                    .buttonStyle(.registry)
            }
            DemoRow {
                Button("Secondary") {}
                    .buttonStyle(.registrySecondary)
                Button("Ghost") {}
                    .buttonStyle(.registryGhost)
                Button("Link") {}
                    .buttonStyle(.registryLink)
            }
            DemoRow {
                Button("Disabled") {}
                    .buttonStyle(.registry)
                    .disabled(true)
                Button("Small", systemImage: "plus") {}
                    .buttonStyle(.registryOutline)
                    .controlSize(.small)
                Button("Large") {}
                    .buttonStyle(.registrySecondary)
                    .controlSize(.large)
            }
        }
    }
}

struct ButtonGroupDemo: View {
    var body: some View {
        DemoSurface {
            ControlGroup {
                Button("Undo", systemImage: "arrow.uturn.backward") {}
                Button("Redo", systemImage: "arrow.uturn.forward") {}
            }
            .controlGroupStyle(.registryButtons)

            ControlGroup("Document actions") {
                Button("Save") {}
                Button("Duplicate") {}
                Button("Delete", role: .destructive) {}
            }
            .controlGroupStyle(RegistryButtonGroupStyle(.outline))
        }
    }
}

struct CardDemo: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                LabeledContent("Plan", value: "Premium")
                LabeledContent("Renews", value: "12 September")
                Text("Manage billing and renewal details from your account settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } label: {
            Label("Subscription", systemImage: "creditcard.fill")
        }
        .groupBoxStyle(.registryCard)
    }
}

struct CheckboxDemo: View {
    @State private var accepted = true
    @State private var updates = false

    var body: some View {
        DemoSurface {
            Toggle("Accept terms", isOn: $accepted)
                .toggleStyle(.registryCheckbox)
            Toggle("Product updates", isOn: $updates)
                .toggleStyle(.registryCheckbox)
            Toggle("Unavailable option", isOn: .constant(false))
                .toggleStyle(.registryCheckbox)
                .disabled(true)
        }
    }
}

struct InputDemo: View {
    @Environment(\.registryTheme) private var theme
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        DemoSurface {
            TextField("Email", text: $email)
                .textFieldStyle(.registryInput)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
                .textFieldStyle(.registryInput)
            VStack(alignment: .leading, spacing: 4) {
                TextField("Email", text: .constant("not-an-email"))
                    .textFieldStyle(RegistryInputStyle(isInvalid: true))
                    .accessibilityHint("Enter a valid email address")
                Text("Enter a valid email address")
                    .font(.footnote)
                    .foregroundStyle(theme.negative)
            }
            TextField("Disabled", text: .constant("Unavailable"))
                .textFieldStyle(.registryInput)
                .disabled(true)
        }
    }
}

struct LabelDemo: View {
    var body: some View {
        DemoSurface {
            Label("Account settings", systemImage: "person.crop.circle")
                .labelStyle(.registry)
            Label("Continue", systemImage: "chevron.forward")
                .labelStyle(.registryTrailingIcon)
        }
    }
}

struct MacroProgressDemo: View {
    var body: some View {
        DemoSurface {
            MacroProgress(
                "Protein",
                value: Text("96 g"),
                target: Text("130 g"),
                progress: 96.0 / 130.0,
                systemImage: "fish.fill",
                tint: .indigo
            )
            MacroProgress(
                "Carbohydrates",
                value: Text("182 g"),
                target: Text("240 g"),
                progress: 182.0 / 240.0,
                systemImage: "leaf.fill",
                tint: .green
            )
        }
    }
}

struct MetricCardDemo: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) { metrics }
            VStack(spacing: 16) { metrics }
        }
    }

    @ViewBuilder
    private var metrics: some View {
        MetricCard(
            "Available balance",
            value: Text(12_480.32, format: .currency(code: "USD")),
            detail: Text("Up 8.2% this month"),
            systemImage: "creditcard.fill"
        )
        MetricCard(
            "Monthly change",
            value: Text(0.082, format: .percent.precision(.fractionLength(1))),
            systemImage: "chart.line.uptrend.xyaxis"
        )
    }
}

struct ProgressDemo: View {
    var body: some View {
        DemoSurface {
            ProgressView(value: 0.68) {
                Text("Uploading")
            } currentValueLabel: {
                Text("68 percent")
            }
            .progressViewStyle(.registryLinear)

            ProgressView("Preparing files")
                .progressViewStyle(.registryLinear)

            ProgressView(value: 1) {
                Text("Import complete")
            }
            .progressViewStyle(.registryLinearPositive)

            ProgressView(value: 0.32) {
                Text("Upload interrupted")
            }
            .progressViewStyle(.registryLinearNegative)
        }
    }
}

struct SelectDemo: View {
    @State private var currency = "KWD"

    var body: some View {
        DemoSurface {
            Picker("Currency", selection: $currency) {
                Text("Kuwaiti dinar").tag("KWD")
                Text("US dollar").tag("USD")
                Text("Euro").tag("EUR")
            }
            .registrySelect()

            Picker("Unavailable", selection: .constant("KWD")) {
                Text("Kuwaiti dinar").tag("KWD")
            }
            .registrySelect()
            .disabled(true)
        }
    }
}

struct SeparatorDemo: View {
    var body: some View {
        DemoSurface {
            Text("Account")
            Divider()
                .registrySeparator(insets: EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            HStack(spacing: 16) {
                Text("Profile")
                Divider().registrySeparator(.vertical)
                Text("Security")
            }
            .frame(height: 44)
        }
    }
}

struct SpinnerDemo: View {
    var body: some View {
        DemoSurface {
            ProgressView()
                .accessibilityLabel("Loading")
                .progressViewStyle(.registrySpinner)
            ProgressView("Loading results")
                .progressViewStyle(.registrySpinner)
        }
    }
}

struct TextareaDemo: View {
    @Environment(\.registryTheme) private var theme
    @State private var notes = "Leave the parcel with the concierge."

    var body: some View {
        DemoSurface {
            TextEditor(text: $notes)
                .registryTextArea(accessibilityLabel: Text("Delivery instructions"))
            VStack(alignment: .leading, spacing: 4) {
                TextEditor(text: .constant("Too short"))
                    .registryTextArea(
                        accessibilityLabel: Text("Request details"),
                        isInvalid: true,
                        minimumHeight: 80
                    )
                    .accessibilityHint("Enter at least 20 characters")
                Text("Enter at least 20 characters")
                    .font(.footnote)
                    .foregroundStyle(theme.negative)
            }
        }
    }
}

struct ToggleDemo: View {
    @State private var bold = true
    @State private var italic = false

    var body: some View {
        DemoSurface {
            HStack(spacing: 12) {
                Toggle("Bold", systemImage: "bold", isOn: $bold)
                Toggle("Italic", systemImage: "italic", isOn: $italic)
            }
            .labelStyle(.iconOnly)
            .toggleStyle(.registryToggle)
        }
    }
}

struct ToggleGroupDemo: View {
    @State private var bold = true
    @State private var italic = false
    @State private var underline = false

    var body: some View {
        DemoSurface {
            ControlGroup("Text formatting") {
                Toggle("Bold", systemImage: "bold", isOn: $bold)
                Toggle("Italic", systemImage: "italic", isOn: $italic)
                Toggle("Underline", systemImage: "underline", isOn: $underline)
            }
            .labelStyle(.iconOnly)
            .registryToggleGroup()
        }
    }
}

struct TransactionRowDemo: View {
    var body: some View {
        DemoSurface {
            TransactionRow(
                title: Text("Mishmash Bakery"),
                subtitle: Text("Today, 09:41"),
                amount: Text(-8.75, format: .currency(code: "KWD")),
                systemImage: "cup.and.saucer.fill",
                tone: .negative
            )
            Divider().registrySeparator()
            TransactionRow(
                title: Text("Salary"),
                subtitle: Text("Yesterday"),
                amount: Text(2_450, format: .currency(code: "KWD")),
                systemImage: "building.columns.fill",
                tone: .positive
            )
            Divider().registrySeparator()
            TransactionRow(
                title: Text("Pending transfer"),
                subtitle: Text("Yesterday"),
                amount: Text(120, format: .currency(code: "KWD")),
                systemImage: "arrow.left.arrow.right"
            )
        }
    }
}

struct AlertDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            InlineAlert(
                "Card delivery delayed",
                message: Text("Your new card now arrives on Thursday.")
            )
            InlineAlert(
                "Import complete",
                message: Text("124 transactions were added."),
                variant: .positive
            )
            InlineAlert(
                "Payment failed",
                message: Text("The card on file was declined."),
                variant: .destructive
            ) {
                HStack {
                    Button("Retry") {}
                        .buttonStyle(.registry)
                    Button("Change card") {}
                        .buttonStyle(.registryOutline)
                }
            }
        }
    }
}

struct AvatarDemo: View {
    var body: some View {
        DemoSurface {
            HStack(spacing: 12) {
                Avatar(
                    Image(systemName: "person.crop.circle.fill"),
                    accessibilityLabel: Text("Mishmash Bakery")
                )
                Avatar(initials: "MK", accessibilityLabel: Text("Maya Khalid"))
                Avatar(accessibilityLabel: Text("Unknown sender"))
            }
            HStack(alignment: .bottom, spacing: 12) {
                Avatar(initials: "S", accessibilityLabel: Text("Salary"))
                    .controlSize(.mini)
                Avatar(initials: "S", accessibilityLabel: Text("Salary"))
                    .controlSize(.small)
                Avatar(initials: "S", accessibilityLabel: Text("Salary"))
                Avatar(initials: "S", accessibilityLabel: Text("Salary"))
                    .controlSize(.large)
                Avatar(initials: "S", accessibilityLabel: Text("Salary"))
                    .controlSize(.extraLarge)
            }
        }
    }
}

struct SkeletonDemo: View {
    @Environment(\.registryTheme) private var theme
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.standardSpacing) {
            Toggle("Loading", isOn: $isLoading)
                .toggleStyle(.switch)

            DemoSurface {
                ForEach(0..<3, id: \.self) { index in
                    ItemRow(
                        title: Text("Mishmash Bakery order \(index + 1)"),
                        description: Text("Card payment of KWD 8.750")
                    ) {
                        Avatar(initials: "MB", accessibilityLabel: Text("Mishmash Bakery"))
                    } accessory: {
                        Text("09:4\(index)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .registrySkeleton(isLoading)
        }
    }
}

struct EmptyDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            ContentUnavailableView(
                "No recent activity",
                systemImage: "clock.arrow.circlepath",
                description: Text("New transactions will appear here.")
            )
            .registryEmptyState()

            ContentUnavailableView {
                Label("No results for “bakery”", systemImage: "magnifyingglass")
            } description: {
                Text("Check the spelling or try a broader search.")
            } actions: {
                Button("Clear search") {}
                    .buttonStyle(.registryOutline)
            }
            .registryEmptyState()
        }
    }
}

struct AccordionDemo: View {
    @Environment(\.registryTheme) private var theme
    @State private var isFirstExpanded = true
    @State private var isSecondExpanded = false
    @State private var isThirdExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            DisclosureGroup("Is my card contactless?", isExpanded: $isFirstExpanded) {
                Text("Yes. Hold it near the terminal until it confirms the payment.")
            }
            Divider().registrySeparator()
            DisclosureGroup("How do I freeze my card?", isExpanded: $isSecondExpanded) {
                Text("Open the card, then choose Freeze. Unfreeze the same way.")
            }
            Divider().registrySeparator()
            DisclosureGroup("Can I change my PIN?", isExpanded: $isThirdExpanded) {
                Text("Yes, from the card's settings or at any of our ATMs.")
            }
        }
        .disclosureGroupStyle(.registryAccordion)
        .padding(.horizontal, theme.metrics.standardSpacing)
        .registrySurface()
    }
}

struct ItemDemo: View {
    @Environment(\.registryTheme) private var theme
    @State private var limitEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            Button {} label: {
                ItemRow(
                    title: Text("Mishmash Bakery"),
                    description: Text("Card ending 4021 · Today, 09:41")
                ) {
                    Avatar(initials: "MB", accessibilityLabel: Text("Mishmash Bakery"))
                } accessory: {
                    Image(systemName: "chevron.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, theme.metrics.standardSpacing)
            }
            .buttonStyle(.plain)

            Divider().registrySeparator()

            ItemRow(
                title: Text("Statement ready"),
                description: Text("August 2026"),
                accessory: {
                    Text("New").registryBadge()
                }
            )
            .padding(.vertical, theme.metrics.standardSpacing)

            Divider().registrySeparator()

            ItemRow(
                title: Text("Spending limit"),
                description: Text("Applies to online purchases."),
                accessory: {
                    Toggle("Spending limit", isOn: $limitEnabled)
                        .labelsHidden()
                }
            )
            .padding(.vertical, theme.metrics.standardSpacing)
        }
        .padding(.horizontal, theme.metrics.standardSpacing)
        .registrySurface()
    }
}
