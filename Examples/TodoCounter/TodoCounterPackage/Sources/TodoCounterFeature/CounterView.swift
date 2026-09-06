import ComposableArchitecture
import SwiftUI
import SwiftUIRegistryFoundations

struct CounterView: View {
    let store: StoreOf<Counter>
    @Environment(\.registryTheme) private var theme

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
                                .registryBadge(store.isPrime ? .positive : .outline)
                            Text(store.count.isMultiple(of: 2) ? "Even" : "Odd")
                                .registryBadge(.secondary)
                        }
                        HStack(spacing: theme.metrics.standardSpacing) {
                            Button {
                                store.send(.decrementButtonTapped, animation: .default)
                            } label: {
                                Image(systemName: "minus")
                            }
                            .buttonStyle(.registryOutline)
                            .accessibilityLabel("Decrement")
                            Button {
                                store.send(.incrementButtonTapped, animation: .default)
                            } label: {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.registry)
                            .accessibilityLabel("Increment")
                        }
                        .controlSize(.large)
                        Button("Reset") { store.send(.resetButtonTapped, animation: .default) }
                            .buttonStyle(.registryGhost)
                            .disabled(store.count == 0)
                    }
                    .frame(maxWidth: .infinity)
                } label: {
                    Label("Counter", systemImage: "number")
                }
                .groupBoxStyle(.registryCard)

                Text("The Point-Free counter: state in a reducer, styling from registry items you own.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Counter")
    }
}

#Preview("Counter") {
    NavigationStack {
        CounterView(store: Store(initialState: Counter.State(count: 7)) { Counter() })
    }
    .registryTheme(.app)
    .fontDesign(.rounded)
}
