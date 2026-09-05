import Foundation
import Testing
@testable import SwiftUIRegistryShowcaseFeature

/// The Showcase speaks the same preset codes as `Scripts/preset.py` and the
/// website: every vector pinned by the Python reference must encode and
/// decode identically here, or a code copied from the Tune panel would mean
/// something else on the website.
struct ThemePresetTests {
    struct Document: Decodable {
        let vectors: [Vector]
    }

    struct Vector: Decodable {
        let name: String
        let code: String
        let tuning: Knobs
    }

    struct Knobs: Decodable {
        let accent: String
        let darkLabelOnAccent: Bool
        let surfaceOpacity: Double
        let borderOpacity: Double
        let borderWidth: Double
        let emphasizedBorderWidth: Double
        let compactRadius: Double
        let controlRadius: Double
        let cardRadius: Double
        let compactSpacing: Double
        let standardSpacing: Double
        let sectionSpacing: Double
        let controlHorizontalPadding: Double
        let disabledOpacity: Double
        let customAccent: String?
        let customAccentDark: String?
    }

    static let vectors: [Vector] = {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<6 { url.deleteLastPathComponent() }
        url.append(path: "Tests/RegistryTests/preset_vectors.json")
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(Document.self, from: data).vectors
    }()

    static func vector(named prefix: String) -> Vector {
        vectors.first { $0.name.hasPrefix(prefix) }!
    }

    static func tuning(from knobs: Knobs) -> ThemeTuning {
        var tuning = ThemeTuning.default
        tuning.accent = ThemeTuning.Accent(rawValue: knobs.accent)!
        tuning.darkLabelOnAccent = knobs.darkLabelOnAccent
        tuning.surfaceOpacity = knobs.surfaceOpacity
        tuning.borderOpacity = knobs.borderOpacity
        tuning.borderWidth = knobs.borderWidth
        tuning.emphasizedBorderWidth = knobs.emphasizedBorderWidth
        tuning.compactRadius = knobs.compactRadius
        tuning.controlRadius = knobs.controlRadius
        tuning.cardRadius = knobs.cardRadius
        tuning.compactSpacing = knobs.compactSpacing
        tuning.standardSpacing = knobs.standardSpacing
        tuning.sectionSpacing = knobs.sectionSpacing
        tuning.controlHorizontalPadding = knobs.controlHorizontalPadding
        tuning.disabledOpacity = knobs.disabledOpacity
        if let hex = knobs.customAccent { tuning.customAccent = rgb(hex) }
        tuning.customAccentDark = knobs.customAccentDark.map(rgb)
        return tuning
    }

    static func rgb(_ hex: String) -> ThemeTuning.RGB {
        ThemeTuning.RGB(packed: Int(hex.dropFirst(), radix: 16)!)
    }

    static func hex(_ rgb: ThemeTuning.RGB) -> String {
        String(format: "#%06X", rgb.packed)
    }

    static func knobs(of tuning: ThemeTuning) -> [Double] {
        [
            tuning.surfaceOpacity, tuning.borderOpacity, tuning.borderWidth, tuning.emphasizedBorderWidth,
            tuning.compactRadius, tuning.controlRadius, tuning.cardRadius, tuning.compactSpacing,
            tuning.standardSpacing, tuning.sectionSpacing, tuning.controlHorizontalPadding, tuning.disabledOpacity,
        ]
    }

    @Test func `Every pinned vector encodes to its code`() {
        #expect(Self.vectors.count >= 20)
        for vector in Self.vectors {
            #expect(Self.tuning(from: vector.tuning).presetCode == vector.code, "\(vector.name)")
        }
    }

    @Test func `Every pinned code decodes to its knobs`() {
        for vector in Self.vectors {
            let decoded = ThemeTuning(presetCode: vector.code)
            let expected = Self.tuning(from: vector.tuning)
            #expect(decoded?.accent == expected.accent, "\(vector.name)")
            #expect(decoded?.darkLabelOnAccent == expected.darkLabelOnAccent, "\(vector.name)")
            for (actual, wanted) in zip(Self.knobs(of: decoded ?? .default), Self.knobs(of: expected)) {
                #expect(abs(actual - wanted) < 1e-9, "\(vector.name)")
            }
            if expected.accent == .custom {
                #expect(decoded.map { Self.hex($0.customAccent) } == vector.tuning.customAccent, "\(vector.name)")
                #expect(decoded?.customAccentDark.map(Self.hex) == vector.tuning.customAccentDark, "\(vector.name)")
            } else {
                #expect(decoded?.customAccentDark == nil, "\(vector.name)")
            }
        }
    }

    // Environment switches are never part of a theme, so a code leaves them
    // to the base it decodes over.
    @Test func `Decoding keeps the environment of the base`() {
        var base = ThemeTuning.default
        base.rightToLeft = true
        base.textSize = .accessibility
        let decoded = ThemeTuning(presetCode: Self.vector(named: "Amber").code, base: base)
        #expect(decoded?.accent == .yellow)
        #expect(decoded?.darkLabelOnAccent == true)
        #expect(decoded?.rightToLeft == true)
        #expect(decoded?.textSize == .accessibility)
    }

    @Test func `Invalid codes are refused rather than guessed`() {
        for code in ["", "a", "b13GkaOXWwIC", "a13GkaOXWwI-", "a" + String(repeating: "z", count: 22), "aF"] {
            #expect(ThemeTuning(presetCode: code) == nil, "\(code)")
        }
        #expect(ThemeTuning.presetCode(in: "--preset a13GkaOXWwIC") == "a13GkaOXWwIC")
        #expect(ThemeTuning.presetCode(in: "  a13GkaOXWwIC \n") == "a13GkaOXWwIC")
        #expect(ThemeTuning.presetCode(in: "zz") == nil)
    }

    @Test func `Knobs off the slider grid snap on encode`() {
        var tuning = ThemeTuning.default
        tuning.cardRadius = 18.3
        tuning.surfaceOpacity = 0.9
        tuning.compactSpacing = 1
        let decoded = ThemeTuning(presetCode: tuning.presetCode)
        #expect(decoded?.cardRadius == 18)
        #expect(decoded?.surfaceOpacity == 0.2)
        #expect(decoded?.compactSpacing == 4)
    }

    @Test func `Import takes a code before it looks for Swift`() {
        let graphite = Self.vector(named: "Graphite")
        let imported = ThemeTuning.parse("--preset \(graphite.code)")
        #expect(imported?.accent == .ink)
        #expect(imported?.surfaceOpacity == 0.05)
        #expect(imported?.presetCode == graphite.code)
        #expect(ThemeTuning.parse("nothing here") == nil)
    }

    // The export lists the dark color first; an import that read the first
    // color as the light one would silently swap a designer's two accents.
    @Test func `A dual custom accent survives the Swift export and import`() {
        var tuning = ThemeTuning.default
        tuning.accent = .custom
        tuning.customAccent = ThemeTuning.RGB(red: 0.1, green: 0.2, blue: 0.3)
        tuning.customAccentDark = ThemeTuning.RGB(red: 0.6, green: 0.7, blue: 0.8)
        let imported = ThemeTuning.parse(tuning.swiftSource)
        #expect(imported?.accent == .custom)
        #expect(imported.map { Self.hex($0.customAccent) } == Self.hex(tuning.customAccent))
        #expect(imported?.customAccentDark.map(Self.hex) == Self.hex(tuning.customAccentDark!))
    }
}
