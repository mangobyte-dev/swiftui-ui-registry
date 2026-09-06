import ComposableArchitecture
import SwiftUI

struct HandmadeCounterView: View {
    let store: StoreOf<Counter>
    @Environment(\.handmadeTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(spacing: theme.metrics.sectionSpacing) {
                GroupBox {
                    VStack(spacing: theme.metrics.standardSpacing) {
                        Text("\(store.count)")
                            .font(.system(size: 88, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .accessibilityLabel("Count \(store.count)")
                        HStack(spacing: theme.metrics.compactSpacing) {
                            Text(store.isPrime ? "Prime" : "Not prime")
                                .handmadeBadge(store.isPrime ? .positive : .outline)
                            Text(store.count.isMultiple(of: 2) ? "Even" : "Odd")
                                .handmadeBadge(.secondary)
                        }
                        HStack(spacing: theme.metrics.standardSpacing) {
                            Button {
                                store.send(.decrementButtonTapped, animation: .default)
                            } label: {
                                Image(systemName: "minus")
                            }
                            .buttonStyle(.handmadeOutline)
                            .accessibilityLabel("Decrement")
                            Button {
                                store.send(.incrementButtonTapped, animation: .default)
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.handmade)
                            .accessibilityLabel("Increment")
                        }
                        .controlSize(.large)
                        Button("Reset") { store.send(.resetButtonTapped, animation: .default) }
                            .buttonStyle(.handmadeGhost)
                            .disabled(store.count == 0)
                    }
                    .frame(maxWidth: .infinity)
                } label: {
                    Label("Counter", systemImage: "number")
                }
                .groupBoxStyle(.handmadeCard)

                Text("The Point-Free counter: state in a reducer, styling written by hand in this app.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Counter")
    }
}
