import Foundation
import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        if ProcessInfo.processInfo.arguments.contains("-stage-one") {
            StageOneShowcase()
        } else {
            TabView {
                Tab("Finance", systemImage: "creditcard") {
                    ShowcaseScreen {
                        FinanceOverview(
                            "Overview",
                            balanceTitle: "Available balance",
                            balance: Text(12_480.32, format: .currency(code: "USD")),
                            changeTitle: "Monthly change",
                            change: Text(0.082, format: .percent.precision(.fractionLength(1))),
                            sectionTitle: "Recent activity",
                            transactions: financeTransactions,
                            emptyDescription: Text("New transactions will appear here."),
                            onSelect: { _ in }
                        )
                    }
                }

                Tab("Nutrition", systemImage: "fork.knife") {
                    ShowcaseScreen {
                        NutritionOverview(
                            "Today",
                            energyTitle: "Energy",
                            energy: Text("1,640 kcal"),
                            energyDetail: Text("360 kcal remaining"),
                            sectionTitle: "Macronutrients",
                            macros: [
                                NutritionMacroItem(
                                    id: "protein",
                                    name: "Protein",
                                    value: Text("96 g"),
                                    target: Text("130 g"),
                                    progress: 96.0 / 130.0,
                                    systemImage: "fish.fill",
                                    tint: .indigo
                                ),
                                NutritionMacroItem(
                                    id: "carbs",
                                    name: "Carbohydrates",
                                    value: Text("182 g"),
                                    target: Text("240 g"),
                                    progress: 182.0 / 240.0,
                                    systemImage: "leaf.fill",
                                    tint: .green
                                ),
                                NutritionMacroItem(
                                    id: "fat",
                                    name: "Fat",
                                    value: Text("48 g"),
                                    target: Text("65 g"),
                                    progress: 48.0 / 65.0,
                                    systemImage: "drop.fill",
                                    tint: .orange
                                )
                            ],
                            actionTitle: "Log food",
                            onLogFood: {}
                        )
                    }
                }

                Tab("Authentication", systemImage: "person.badge.key") {
                    ShowcaseScreen {
                        AuthenticationDemo()
                    }
                }

                Tab("Settings", systemImage: "gearshape") {
                    ShowcaseScreen {
                        SettingsDemo()
                    }
                }
            }
            .tint(.indigo)
        }
    }
}

private extension ContentView {
    var financeTransactions: [FinanceTransactionItem<String>] {
        guard !ProcessInfo.processInfo.arguments.contains("-empty-finance") else {
            return []
        }

        return [
            FinanceTransactionItem(
                id: "bakery",
                title: Text("Mishmash Bakery"),
                subtitle: Text("Today, 09:41"),
                amount: Text(-8.75, format: .currency(code: "KWD")),
                systemImage: "cup.and.saucer.fill",
                tone: .negative
            ),
            FinanceTransactionItem(
                id: "salary",
                title: Text("Salary"),
                subtitle: Text("Yesterday"),
                amount: Text(2_450, format: .currency(code: "KWD")),
                systemImage: "building.columns.fill",
                tone: .positive
            ),
            FinanceTransactionItem(
                id: "mobile",
                title: Text("Mobile service"),
                subtitle: Text("Monday"),
                amount: Text(-18, format: .currency(code: "KWD")),
                systemImage: "antenna.radiowaves.left.and.right",
                tone: .negative
            )
        ]
    }
}

/// Harness state for the installed auth block: local validation and a fake
/// submit that flips `isSubmitting` and then reports a form error, so UI tests
/// can exercise validation and disabled states deterministically without
/// networking.
private struct AuthenticationDemo: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: LocalizedStringResource?
    @State private var passwordError: LocalizedStringResource?
    @State private var formError: LocalizedStringResource?
    @State private var isSubmitting = false

    var body: some View {
        AuthForm(
            "Welcome back",
            identity: $email,
            identityError: emailError,
            password: $password,
            passwordError: passwordError,
            formError: formError,
            isSubmitting: isSubmitting,
            secondaryActionTitle: "Forgot password?",
            onSecondaryAction: {},
            onSubmit: submit
        )
    }

    private func submit() {
        emailError = email.contains("@") ? nil : "Enter a valid email address"
        passwordError = password.isEmpty ? "Enter your password" : nil
        formError = nil
        guard emailError == nil, passwordError == nil else { return }
        isSubmitting = true
        Task {
            // Two seconds keeps the submitting window long enough for the UI
            // tests to observe the disabled controls deterministically.
            try? await Task.sleep(for: .seconds(2))
            isSubmitting = false
            formError = "We could not sign you in. Try again."
        }
    }
}

/// Harness state for the installed settings block: caller-owned toggle and
/// selection bindings, one organization-managed disabled row, and a
/// destructive sign-out action. The captions under the section mirror the
/// bindings so UI tests can prove control writes flow through caller state.
private struct SettingsDemo: View {
    @State private var alertsEnabled = true
    @State private var summaryEnabled = false
    @State private var marketingEnabled = false
    @State private var currency = "KWD"
    @State private var didSignOut = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSection(
                "Notifications",
                footer: Text("Quiet hours apply to every channel.")
            ) {
                Toggle("Transaction alerts", isOn: $alertsEnabled)
                    .settingsRowDescription(
                        Text("A push notification for every card transaction.")
                    )

                Toggle("Weekly summary", isOn: $summaryEnabled)

                Toggle("Marketing messages", isOn: $marketingEnabled)
                    .settingsRowDisabled(
                        explanation: Text("Managed by your organization's privacy policy.")
                    )

                LabeledContent("Currency") {
                    Picker("Currency", selection: $currency) {
                        Text("Kuwaiti dinar").tag("KWD")
                        Text("US dollar").tag("USD")
                    }
                    .registrySelect()
                }

                Button(role: .destructive) {
                    didSignOut = true
                } label: {
                    Text("Sign out")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.registry)
            }

            Text(
                alertsEnabled
                    ? "Transaction alerts are on."
                    : "Transaction alerts are off."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            if didSignOut {
                Text("Signed out.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ShowcaseScreen<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            content
                .padding()
                .containerRelativeFrame(.horizontal) { length, _ in
                    min(length, 792)
                }
        }
    }
}

#Preview("Installed Registry Showcase") {
    ContentView()
}
