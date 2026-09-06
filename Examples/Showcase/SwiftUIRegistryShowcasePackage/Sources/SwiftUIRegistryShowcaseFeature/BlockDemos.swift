import Foundation
import SwiftUI
import SwiftUIRegistryFoundations

// Harness state for the installed blocks. Validation, fake submission, and
// loading toggles live here in the consumer, never inside the blocks.

struct FinanceDemo: View {
    var body: some View {
        FinanceOverview(
            "Overview",
            balanceTitle: "Available balance",
            balance: Text(12_480.32, format: .currency(code: "USD")),
            changeTitle: "Monthly change",
            change: Text(0.082, format: .percent.precision(.fractionLength(1))),
            sectionTitle: "Recent activity",
            transactions: transactions,
            emptyDescription: Text("New transactions will appear here."),
            onSelect: { _ in }
        )
    }

    private var transactions: [FinanceTransactionItem<String>] {
        guard !LaunchArguments.current.contains("-empty-finance") else {
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

struct NutritionDemo: View {
    var body: some View {
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

/// Local validation and a fake submit that flips `isSubmitting` and then
/// reports a form error, so UI tests can exercise validation and disabled
/// states deterministically without networking.
struct AuthenticationDemo: View {
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
        // The fake submission is a task tied to the view, so it is cancelled
        // if the screen goes away mid-flight instead of writing into it.
        .task(id: isSubmitting) {
            guard isSubmitting else { return }
            // Two seconds keeps the submitting window long enough for the UI
            // tests to observe the disabled controls deterministically.
            do {
                try await Task.sleep(for: .seconds(2))
            } catch {
                return
            }
            isSubmitting = false
            formError = "We could not sign you in. Try again."
        }
    }

    private func submit() {
        emailError = email.contains("@") ? nil : "Enter a valid email address"
        passwordError = password.isEmpty ? "Enter your password" : nil
        formError = nil
        guard emailError == nil, passwordError == nil else { return }
        isSubmitting = true
    }
}

/// Caller-owned toggle and selection bindings, one organization-managed
/// disabled row, and a destructive sign-out action. The captions under the
/// section mirror the bindings so UI tests can prove control writes flow
/// through caller state.
struct SettingsDemo: View {
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

/// Caller-owned feed state with a picker to switch between loaded, loading,
/// and empty so every Stage 3 state is reachable in one screen; the capture
/// launch shows the loaded state.
struct ActivityFeedDemo: View {
    enum FeedState: String, CaseIterable, Identifiable {
        case loaded, loading, empty
        var id: String { rawValue }
    }

    @State private var state: FeedState = .loaded
    @State private var noticeDismissed = false
    @State private var selected: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Feed state", selection: $state) {
                ForEach(FeedState.allCases) { state in
                    Text(state.rawValue.capitalized).tag(state)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("activity.state")

            ActivityFeed(
                "Activity",
                notice: noticeDismissed || state == .empty
                    ? nil
                    : ActivityNotice(
                        "Card delivery delayed",
                        message: Text("Your new card now arrives on Thursday.")
                    ),
                onDismissNotice: { noticeDismissed = true },
                items: state == .empty ? [] : items,
                earlierItems: state == .empty ? [] : earlierItems,
                isLoading: state == .loading,
                emptyDescription: Text("New activity will appear here."),
                onSelect: { selected = $0 }
            )

            if let selected {
                Text("Selected \(selected).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var items: [ActivityItem<String>] {
        [
            ActivityItem(
                id: "bakery",
                title: Text("Mishmash Bakery"),
                detail: Text("Card payment of KWD 8.750"),
                timestamp: Text("09:41"),
                initials: "MB",
                senderName: Text("Mishmash Bakery"),
                isUnread: true
            ),
            ActivityItem(
                id: "salary",
                title: Text("Salary received"),
                detail: Text("KWD 2,450.000 from Harbor Bank"),
                timestamp: Text("Yesterday"),
                initials: "HB",
                senderName: Text("Harbor Bank")
            ),
            ActivityItem(
                id: "statement",
                title: Text("Statement ready"),
                detail: Text("August 2026"),
                timestamp: Text("Monday"),
                initials: "ST",
                senderName: Text("Statements")
            )
        ]
    }

    private var earlierItems: [ActivityItem<String>] {
        [
            ActivityItem(
                id: "mobile",
                title: Text("Mobile service"),
                detail: Text("Card payment of KWD 18.000"),
                timestamp: Text("28 Aug"),
                initials: "MS",
                senderName: Text("Mobile service")
            )
        ]
    }
}

/// Caller-owned query and filtering for the command-search block; the caption
/// under the screen reports the selection so UI tests can prove it.
struct CommandSearchDemo: View {
    @State private var query = ""
    @State private var selected: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CommandSearch(
                "Search",
                query: $query,
                prompt: "Search actions and activity",
                sections: DemoCommands.sections(matching: query),
                emptyDescription: Text("Try a payee, a card, or an action."),
                shortcuts: [
                    CommandShortcutHint("Open search", keys: "⌘K", keysLabel: Text("Command K")),
                    CommandShortcutHint("Run the highlighted command", keys: "↩", keysLabel: Text("Return")),
                ],
                onSelect: { selected = $0 }
            )

            if let selected {
                Text("Ran \(selected).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// The theme preview wall. The capture route wraps it in a scroll view, so the
/// demo is the block itself with no chrome of its own.
struct PreviewDemo: View {
    var body: some View {
        PreviewWall()
    }
}

/// The second theme preview wall. The capture route wraps it in a scroll view,
/// so the demo is the block itself with no chrome of its own.
struct Preview02Demo: View {
    var body: some View {
        PreviewWall02()
    }
}
