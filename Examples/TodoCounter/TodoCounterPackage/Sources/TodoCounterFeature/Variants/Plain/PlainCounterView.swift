import ComposableArchitecture
import SwiftUI

struct PlainCounterView: View {
    let store: StoreOf<Counter>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GroupBox {
                    VStack(spacing: 16) {
                        Text("\(store.count)")
                            .font(.largeTitle)
                            .monospacedDigit()
                            .accessibilityLabel("Count \(store.count)")
                        HStack {
                            Text(store.isPrime ? "Prime" : "Not prime")
                            Text(store.count.isMultiple(of: 2) ? "Even" : "Odd")
                        }
                        .font(.caption)
                        HStack(spacing: 16) {
                            Button {
                                store.send(.decrementButtonTapped, animation: .default)
                            } label: {
                                Image(systemName: "minus")
                            }
                            .accessibilityLabel("Decrement")
                            Button {
                                store.send(.incrementButtonTapped, animation: .default)
                            } label: {
                                Image(systemName: "plus")
                            }
                            .accessibilityLabel("Increment")
                        }
                        Button("Reset") { store.send(.resetButtonTapped, animation: .default) }
                            .disabled(store.count == 0)
                    }
                    .frame(maxWidth: .infinity)
                } label: {
                    Label("Counter", systemImage: "number")
                }

                Text("The Point-Free counter on stock SwiftUI controls with no styling.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Counter")
    }
}
