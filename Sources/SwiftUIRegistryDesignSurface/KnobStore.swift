#if canImport(UIKit)
import Foundation
import Sharing
import SwiftUIRegistryFoundations

/// One tunable number an item exposes: its name in the item's source, the
/// title the panel shows, its range and step, and the shipped default.
public struct ItemKnob: Identifiable, Sendable, Equatable {
    public let name: String
    public let title: String
    public let range: ClosedRange<Double>
    public let step: Double
    public let shipped: Double
    public var id: String { name }

    public init(_ name: String, title: String? = nil, in range: ClosedRange<Double>, step: Double = 1, shipped: Double) {
        self.name = name
        self.title = title ?? name
        self.range = range
        self.step = step
        self.shipped = shipped
    }
}

extension SharedKey where Self == FileStorageKey<[String: [String: Double]]>.Default {
    /// The tuned knob values by item and knob name, in `design-knobs.json`
    /// beside the design tokens file. A value equal to its shipped default
    /// is never stored, so the file lists only what moved.
    static var designKnobs: Self {
        Self[
            .fileStorage(
                URL.documentsDirectory.appending(component: "design-knobs.json"),
                decoder: nil, encoder: ThemeTuning.fileEncoder),
            default: [:]
        ]
    }
}

/// The knobs the host registered per item, and the tuned values.
@MainActor
final class KnobStore {
    @Shared(.designKnobs) var values
    private(set) var specs: [String: [ItemKnob]] = [:]

    init() {}

    func register(_ knobs: [String: [ItemKnob]]) {
        specs.merge(knobs) { _, new in new }
    }

    func knobs(for item: String) -> [ItemKnob] { specs[item] ?? [] }

    func value(_ item: String, _ knob: ItemKnob) -> Double {
        values[item]?[knob.name] ?? knob.shipped
    }

    /// Writes a value; writing the shipped default deletes the override.
    func set(_ item: String, _ knob: ItemKnob, to value: Double) {
        $values.withLock { values in
            if value == knob.shipped {
                values[item]?[knob.name] = nil
                if values[item]?.isEmpty == true { values[item] = nil }
            } else {
                values[item, default: [:]][knob.name] = value
            }
        }
    }

    func reset(_ item: String) {
        $values.withLock { $0[item] = nil }
    }

    /// What the items read from the environment.
    var environmentValue: RegistryKnobs { RegistryKnobs(values: values) }
}
#endif
