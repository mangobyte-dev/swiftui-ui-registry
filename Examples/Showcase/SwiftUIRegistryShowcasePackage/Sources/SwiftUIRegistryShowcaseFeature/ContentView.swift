import Foundation
import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
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
        }
        .tint(.indigo)
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
