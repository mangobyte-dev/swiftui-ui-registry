import CoreGraphics
import Dependencies
import Foundation
import Sharing
import SwiftUIRegistryFoundations
import Testing
@testable import SwiftUIRegistryDesignSurface

/// What a host can hand the design surface at its boundary, and what the
/// surface must do with it: the tool ships in a host's debug builds and on
/// TestFlight through the host overload, so a wrong knob, a stale token file,
/// or a stacked selection must never crash the app or tune it to something
/// nobody wrote.
@MainActor
struct SurfaceBoundaryTests {
    // MARK: Selection

    @Test func `A pick with nothing under it resolves to no item and an empty chain`() {
        let frames = [(name: "button", frame: CGRect(x: 10, y: 10, width: 100, height: 40))]
        #expect(ItemSelection.pick(frames, at: CGPoint(x: 200, y: 200)) == nil)
        #expect(ItemSelection.chain(frames, at: CGPoint(x: 200, y: 200)).isEmpty)
        #expect(ItemSelection.chain([], at: .zero).isEmpty)
    }

    @Test func `The chain lists the innermost first and each name once`() {
        let frames = [
            (name: "card", frame: CGRect(x: 0, y: 0, width: 300, height: 300)),
            (name: "button", frame: CGRect(x: 20, y: 20, width: 100, height: 40)),
            (name: "button", frame: CGRect(x: 20, y: 20, width: 100, height: 40)),
            (name: "zero", frame: CGRect(x: 20, y: 20, width: 0, height: 0)),
        ]
        let chain = ItemSelection.chain(frames, at: CGPoint(x: 30, y: 30))
        #expect(chain == ["button", "card"], "a zero-area frame contains nothing, a duplicate instance lists once")
    }

    @Test func `Equal areas resolve in a fixed order however the frames arrive`() {
        // Frames come from a dictionary, so their order is not stable; a tie
        // must still pick the same item on every tap.
        let a = (name: "alpha", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let b = (name: "beta", frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let point = CGPoint(x: 50, y: 50)
        #expect(ItemSelection.chain([a, b], at: point) == ItemSelection.chain([b, a], at: point))
        #expect(ItemSelection.pick([b, a], at: point) == "alpha")
    }

    // MARK: Knobs

    @Test func `A knob with a zero step or a shipped value off its range is made usable`() {
        let flat = ItemKnob("padding", in: 0...32, step: 0, shipped: 12)
        #expect(flat.step > 0, "a zero step would trap the slider")
        let outside = ItemKnob("radius", in: 0...16, shipped: 40)
        #expect(outside.shipped == 16, "the shipped value is clamped into the range the slider can show")
        let store = KnobStore()
        store.register(["button": [outside]])
        #expect(store.value("button", outside) == 16)
    }

    @Test func `Registering knobs twice for one item keeps the later registration`() {
        let store = KnobStore()
        let first = ItemKnob("padding", in: 0...32, shipped: 12)
        let second = ItemKnob("padding", in: 0...48, shipped: 16)
        store.register(["button": [first]])
        store.register(["button": [second]])
        #expect(store.knobs(for: "button").map(\.range) == [0...48])
        #expect(store.knobs(for: "button").map(\.shipped) == [16])
    }

    // MARK: Files

    struct SampleTokens: TokenDocument {
        var spacing: Double = 16
        static let shipped = SampleTokens()
        static let fileName = "sample-tokens-boundary.json"
        static let pages: [TokenPage<SampleTokens>] = []
        func apply() {}
    }

    private func temporaryURL() -> URL {
        FileManager.default.temporaryDirectory.appending(component: "boundary-\(UUID().uuidString).json")
    }

    // Sharing keeps file storage in memory under tests, so these two read the
    // real file system on purpose: the file on disk is what fails to decode.
    @Test func `A host token file that fails to decode falls back to the shipped document and is not clobbered`() throws {
        let url = temporaryURL()
        let garbage = Data(#"{"spacing": "wide", "written by": "a newer version"}"#.utf8)
        try garbage.write(to: url)
        let store = withDependencies {
            $0.defaultFileStorage = .fileSystem
        } operation: {
            TokenStore<SampleTokens>(url: url)
        }
        #expect(store.document == .shipped)
        #expect(store.loadFailed, "the failure is surfaced, never guessed over")
        #expect(try Data(contentsOf: url) == garbage, "nothing is written until a change is made")
    }

    @Test func `A registry token file that fails to decode falls back to the defaults`() throws {
        let url = temporaryURL()
        try Data(#"{"tuning": {"accent": "mango"}}"#.utf8).write(to: url)
        let tuning = withDependencies {
            $0.defaultFileStorage = .fileSystem
        } operation: {
            Shared(wrappedValue: ThemeTuning.default, .fileStorage(url, decoder: nil, encoder: ThemeTuning.fileEncoder))
        }
        #expect(tuning.wrappedValue == .default)
        #expect(tuning.loadError != nil)
    }

    // MARK: On this screen

    @Test func `An item scrolled off the stage is not on this screen`() {
        let state = DesignSurfaceState.shared
        state.frames = [:]
        state.stage = CGRect(x: 0, y: 0, width: 400, height: 800)
        state.report(RegistryItemReport(id: UUID(), name: "visible", frame: CGRect(x: 0, y: 100, width: 400, height: 60)))
        state.report(RegistryItemReport(id: UUID(), name: "below", frame: CGRect(x: 0, y: 900, width: 400, height: 60)))
        state.report(RegistryItemReport(id: UUID(), name: "empty", frame: .zero))
        #expect(state.visibleItemNames.map(\.name) == ["visible"])
        state.frames = [:]
        state.stage = .zero
    }

    // MARK: Motion

    @Test func `The tool moves without animation under Reduce Motion`() {
        #expect(ToolChrome.animation(reduceMotion: true) == nil)
        #expect(ToolChrome.animation(reduceMotion: false) != nil)
    }
}
