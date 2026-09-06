import Foundation

/// Preset codes: the tuning knobs as a short shareable string, the same code
/// `swiftui-registry preset` and the website's `/create` page speak. Fields
/// pack little-endian in the reference order into one integer written in
/// base62 behind a version letter; numeric knobs store their slider-grid
/// index. The format rules live in `docs/registry-spec.md` and the pinned
/// vectors in `Registry/preset_vectors.json`.
extension ThemeTuning {
    static let presetVersion: Character = "a"
    private static let presetAlphabet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    private static let presetMaximumLength = 22
    private static let accentBits = 4
    private static let channelBits = 24

    private struct NumericField: Sendable {
        let keyPath: WritableKeyPath<ThemeTuning, Double> & Sendable
        let bits: Int
        let minimum: Double
        let step: Double
        let count: Int
        let decimals: Int

        func index(of value: Double) -> Int {
            let index = Int(((value - minimum) / step).rounded())
            return max(0, min(count - 1, index))
        }

        func value(at index: Int) -> Double {
            let scale = pow(10, Double(decimals))
            return ((minimum + Double(index) * step) * scale).rounded() / scale
        }
    }

    private static let numericFields: [NumericField] = [
        NumericField(keyPath: \.surfaceOpacity, bits: 6, minimum: 0, step: 0.005, count: 41, decimals: 3),
        NumericField(keyPath: \.borderOpacity, bits: 5, minimum: 0, step: 0.01, count: 31, decimals: 2),
        NumericField(keyPath: \.borderWidth, bits: 3, minimum: 0.5, step: 0.5, count: 6, decimals: 1),
        NumericField(keyPath: \.emphasizedBorderWidth, bits: 3, minimum: 1, step: 0.5, count: 7, decimals: 1),
        NumericField(keyPath: \.compactRadius, bits: 4, minimum: 0, step: 1, count: 13, decimals: 0),
        NumericField(keyPath: \.controlRadius, bits: 5, minimum: 0, step: 1, count: 23, decimals: 0),
        NumericField(keyPath: \.cardRadius, bits: 6, minimum: 0, step: 1, count: 33, decimals: 0),
        NumericField(keyPath: \.compactSpacing, bits: 4, minimum: 4, step: 1, count: 13, decimals: 0),
        NumericField(keyPath: \.standardSpacing, bits: 5, minimum: 8, step: 1, count: 25, decimals: 0),
        NumericField(keyPath: \.sectionSpacing, bits: 6, minimum: 12, step: 1, count: 37, decimals: 0),
        NumericField(keyPath: \.controlHorizontalPadding, bits: 5, minimum: 8, step: 1, count: 17, decimals: 0),
        NumericField(keyPath: \.disabledOpacity, bits: 4, minimum: 0.2, step: 0.05, count: 13, decimals: 2),
    ]

    /// Whether the text has the shape of a code: the version letter, then base62.
    static func isPresetCode(_ value: String) -> Bool {
        guard value.count >= 2, value.count <= presetMaximumLength, value.first == presetVersion else { return false }
        return value.dropFirst().allSatisfy { presetAlphabet.contains($0) }
    }

    /// The code inside pasted text: bare, or behind a `--preset` flag.
    static func presetCode(in text: String) -> String? {
        var candidate = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = candidate.range(of: #"^--preset\s+"#, options: .regularExpression) {
            candidate = String(candidate[range.upperBound...])
        }
        return isPresetCode(candidate) ? candidate : nil
    }

    /// The code for these knobs; numeric values snap to their slider grid.
    var presetCode: String {
        var writer = BitWriter()
        writer.write(Accent.allCases.firstIndex(of: accent) ?? 0, bits: Self.accentBits)
        writer.write(darkLabelOnAccent ? 1 : 0, bits: 1)
        for field in Self.numericFields {
            writer.write(field.index(of: self[keyPath: field.keyPath]), bits: field.bits)
        }
        if accent == .custom {
            writer.write(customAccent.packed, bits: Self.channelBits)
            writer.write(customAccentDark == nil ? 0 : 1, bits: 1)
            if let dark = customAccentDark {
                writer.write(dark.packed, bits: Self.channelBits)
            }
        }
        return String(Self.presetVersion) + Self.base62(writer.bits)
    }

    /// The knobs a code carries, over `base` for what a code never stores
    /// (the environment switches and a named accent's remembered custom
    /// color); `nil` when the text is not a valid code.
    init?(presetCode: String, base: ThemeTuning = .default) {
        guard Self.isPresetCode(presetCode), let bits = Self.number(fromBase62: presetCode.dropFirst()) else { return nil }
        var reader = BitReader(bits: bits)
        var tuning = base
        let accentIndex = reader.read(bits: Self.accentBits)
        guard accentIndex < Accent.allCases.count else { return nil }
        tuning.accent = Accent.allCases[accentIndex]
        tuning.darkLabelOnAccent = reader.read(bits: 1) == 1
        for field in Self.numericFields {
            let index = reader.read(bits: field.bits)
            guard index < field.count else { return nil }
            tuning[keyPath: field.keyPath] = field.value(at: index)
        }
        if tuning.accent == .custom {
            tuning.customAccent = RGB(packed: reader.read(bits: Self.channelBits))
            let hasDark = reader.read(bits: 1) == 1
            tuning.customAccentDark = hasDark ? RGB(packed: reader.read(bits: Self.channelBits)) : nil
        }
        self = tuning
    }

    private static func base62(_ number: UInt128) -> String {
        guard number > 0 else { return "0" }
        var digits: [Character] = []
        var remaining = number
        while remaining > 0 {
            digits.append(presetAlphabet[Int(remaining % 62)])
            remaining /= 62
        }
        return String(digits.reversed())
    }

    private static func number(fromBase62 text: Substring) -> UInt128? {
        var number: UInt128 = 0
        for character in text {
            guard let digit = presetAlphabet.firstIndex(of: character) else { return nil }
            let (shifted, overflow) = number.multipliedReportingOverflow(by: 62)
            guard !overflow else { return nil }
            number = shifted + UInt128(digit)
        }
        return number
    }

    private struct BitWriter {
        private(set) var bits: UInt128 = 0
        private var offset = 0

        mutating func write(_ value: Int, bits width: Int) {
            bits |= UInt128(value) << UInt128(offset)
            offset += width
        }
    }

    private struct BitReader {
        let bits: UInt128
        private var offset = 0

        init(bits: UInt128) {
            self.bits = bits
        }

        mutating func read(bits width: Int) -> Int {
            let mask = (UInt128(1) << UInt128(width)) - 1
            let value = (bits >> UInt128(offset)) & mask
            offset += width
            return Int(value)
        }
    }
}

extension ThemeTuning.RGB {
    /// Eight bits per channel, red highest, the way a hex color is written.
    var packed: Int {
        (Self.channel(red) << 16) | (Self.channel(green) << 8) | Self.channel(blue)
    }

    init(packed: Int) {
        self.init(
            red: Double((packed >> 16) & 0xFF) / 255,
            green: Double((packed >> 8) & 0xFF) / 255,
            blue: Double(packed & 0xFF) / 255
        )
    }

    private static func channel(_ value: Double) -> Int {
        max(0, min(255, Int((value * 255).rounded())))
    }
}
