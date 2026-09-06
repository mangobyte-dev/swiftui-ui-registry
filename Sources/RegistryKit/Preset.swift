import Dependencies
import Foundation

public enum Preset {
  public static let siteURL = "https://swiftui-registry.mangobytekw.workers.dev"
  public static let themeFileName = "RegistryTheme+App.swift"
  public static let accents = [
    "system", "ink", "blue", "indigo", "purple", "pink", "red", "orange", "yellow", "green", "mint",
    "teal", "cyan", "brown", "custom",
  ]
  static let alphabet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
  struct Field: Sendable {
    let key: String
    let bits: Int
    let minimum: Double
    let step: Double
    let count: Int
    let decimals: Int
  }
  static let fields: [Field] = [
    .init(key: "surfaceOpacity", bits: 6, minimum: 0, step: 0.005, count: 41, decimals: 3),
    .init(key: "borderOpacity", bits: 5, minimum: 0, step: 0.01, count: 31, decimals: 2),
    .init(key: "borderWidth", bits: 3, minimum: 0.5, step: 0.5, count: 6, decimals: 1),
    .init(key: "emphasizedBorderWidth", bits: 3, minimum: 1, step: 0.5, count: 7, decimals: 1),
    .init(key: "compactRadius", bits: 4, minimum: 0, step: 1, count: 13, decimals: 0),
    .init(key: "controlRadius", bits: 5, minimum: 0, step: 1, count: 23, decimals: 0),
    .init(key: "cardRadius", bits: 6, minimum: 0, step: 1, count: 33, decimals: 0),
    .init(key: "compactSpacing", bits: 4, minimum: 4, step: 1, count: 13, decimals: 0),
    .init(key: "standardSpacing", bits: 5, minimum: 8, step: 1, count: 25, decimals: 0),
    .init(key: "sectionSpacing", bits: 6, minimum: 12, step: 1, count: 37, decimals: 0),
    .init(key: "controlHorizontalPadding", bits: 5, minimum: 8, step: 1, count: 17, decimals: 0),
    .init(key: "disabledOpacity", bits: 4, minimum: 0.2, step: 0.05, count: 13, decimals: 2),
  ]
  public static let defaultTuning: JSON = [
    "accent": "system", "darkLabelOnAccent": false, "surfaceOpacity": 0.055,
    "borderOpacity": 0.08, "borderWidth": 1.0, "emphasizedBorderWidth": 2.0,
    "compactRadius": 6.0, "controlRadius": 8.0, "cardRadius": 16.0,
    "compactSpacing": 8.0, "standardSpacing": 16.0, "sectionSpacing": 24.0,
    "controlHorizontalPadding": 12.0, "disabledOpacity": 0.5,
  ]
  public static func isCode(_ code: String) -> Bool {
    (2...22).contains(code.count) && code.first == "a"
      && code.dropFirst().allSatisfy { alphabet.contains($0) }
  }
  public static func code(in text: String) -> String? {
    var candidate = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if let range = candidate.range(of: "^--preset\\s+", options: .regularExpression) {
      candidate.removeSubrange(range)
    }
    return isCode(candidate) ? candidate : nil
  }
  public static func decode(_ code: String) -> JSON? {
    guard isCode(code) else { return nil }
    // The contract ignores unknown high bits. Wrapping arithmetic also accepts
    // 21 base62 digits whose complete integer exceeds UInt128.
    var bits: UInt128 = 0
    for character in code.dropFirst() {
      bits = bits &* 62 &+ UInt128(alphabet.firstIndex(of: character)!)
    }
    func read(_ width: Int) -> Int {
      let value = Int(bits & ((UInt128(1) << width) - 1))
      bits >>= width
      return value
    }
    let accent = read(4)
    guard accent < accents.count else { return nil }
    var tuning: JSON = [
      "accent": .string(accents[accent]), "darkLabelOnAccent": .bool(read(1) == 1),
    ]
    for field in fields {
      let index = read(field.bits)
      guard index < field.count else { return nil }
      let scale = pow(10, Double(field.decimals))
      tuning[field.key] = .number(
        ((field.minimum + Double(index) * field.step) * scale).rounded(.toNearestOrEven) / scale)
    }
    if accent == 14 {
      tuning["customAccent"] = .string(hex(read(24)))
      tuning["customAccentDark"] = read(1) == 1 ? .string(hex(read(24))) : .null
    }
    return tuning
  }
  public static func encode(_ tuning: JSON) throws -> String {
    guard let accent = accents.firstIndex(of: tuning["accent"].text) else {
      throw RegistryError(
        "accent must be one of \(accents.joined(separator: ", ")), not '\(tuning["accent"].text)'")
    }
    var bits = UInt128(accent)
    var offset = 4
    guard tuning["darkLabelOnAccent"] == .bool(true) || tuning["darkLabelOnAccent"] == .bool(false)
    else { throw RegistryError("darkLabelOnAccent must be one of False, True") }
    if tuning["darkLabelOnAccent"] == .bool(true) { bits |= 1 << offset }
    offset += 1
    for field in fields {
      guard let number = tuning[field.key].number, number.isFinite else {
        throw RegistryError("\(field.key) must be a number")
      }
      let value = max(
        0,
        min(
          Double(field.count - 1), ((number - field.minimum) / field.step).rounded(.toNearestOrEven)
        ))
      bits |= UInt128(value) << offset
      offset += field.bits
    }
    if accent == 14 {
      bits |= UInt128(try rgb(tuning["customAccent"].text)) << offset
      offset += 24
      if let dark = tuning["customAccentDark"].string, !dark.isEmpty {
        bits |= 1 << offset
        offset += 1
        bits |= UInt128(try rgb(dark)) << offset
      }
    }
    var digits: [Character] = []
    repeat {
      digits.append(alphabet[Int(bits % 62)])
      bits /= 62
    } while bits > 0
    return "a" + String(digits.reversed())
  }
  static func rgb(_ color: String) throws -> Int {
    guard matches(color, "^#[0-9A-Fa-f]{6}$"), let bits = Int(color.dropFirst(), radix: 16) else {
      throw RegistryError("a custom accent must be #RRGGBB, not '\(color)'")
    }
    return bits
  }
  static func hex(_ bits: Int) -> String { String(format: "#%06X", bits & 0xffffff) }
  public static func url(_ code: String) -> String { siteURL + "/create?preset=" + code }
  public static func initializerLines(_ tuning: JSON) throws -> [String] {
    func color(_ value: String, ui: Bool) throws -> String {
      let bits = try rgb(value)
      let values = [16, 8, 0].map { String(format: "%.3f", Double((bits >> $0) & 255) / 255) }
      return
        "\(ui ? "UIColor" : "Color")(red: \(values[0]), green: \(values[1]), blue: \(values[2])\(ui ? ", alpha: 1" : ""))"
    }
    func decimal(_ key: String) -> String { String(format: "%.3f", tuning[key].number ?? 0) }
    func points(_ key: String) -> String {
      let number = tuning[key].number ?? 0
      return String(format: number.rounded() == number ? "%.0f" : "%.1f", number)
    }
    let accent = tuning["accent"].text
    var lines = ["RegistryTheme("]
    if accent == "custom", let dark = tuning["customAccentDark"].string, !dark.isEmpty {
      lines += [
        "    accent: Color(uiColor: UIColor { traits in",
        "        traits.userInterfaceStyle == .dark", "            ? \(try color(dark, ui: true))",
        "            : \(try color(tuning["customAccent"].text, ui: true))", "    }),",
      ]
    } else if accent == "custom" {
      lines.append("    accent: \(try color(tuning["customAccent"].text, ui: false)),")
    } else if accent != "system" {
      lines.append("    accent: .\(accent == "ink" ? "primary" : accent),")
    }
    let onAccent =
      accent == "ink"
      ? "Color(uiColor: .systemBackground)"
      : tuning["darkLabelOnAccent"] == .bool(true) ? ".black" : ".white"
    lines += [
      "    onAccent: \(onAccent),", "    surface: .primary.opacity(\(decimal("surfaceOpacity"))),",
      "    border: .primary.opacity(\(decimal("borderOpacity"))),",
      "    disabledOpacity: \(decimal("disabledOpacity")),", "    metrics: RegistryMetrics(",
    ]
    let metrics = [
      "compactSpacing", "standardSpacing", "sectionSpacing", "controlHorizontalPadding",
      "borderWidth", "emphasizedBorderWidth", "compactRadius", "controlRadius", "cardRadius",
    ]
    for key in metrics {
      lines.append("        \(key): \(points(key))\(key == metrics.last ? "" : ",")")
    }
    return lines + ["    )", ")"]
  }
  public static func swiftSource(_ tuning: JSON) throws -> String {
    var lines = try initializerLines(tuning)
    lines[0] = "let theme = " + lines[0]
    lines += [
      "", "// Apply once at the root of your scene; every registry item below inherits it.",
      "ContentView()", "    .registryTheme(theme)",
    ]
    return lines.joined(separator: "\n")
  }
  public static func themeFile(_ tuning: JSON, code: String) throws -> String {
    let body = try initializerLines(tuning)
    var lines = ["import SwiftUI", "import SwiftUIRegistryFoundations"]
    if tuning["accent"] == "ink"
      || (tuning["accent"] == "custom" && tuning["customAccentDark"].string != nil)
    {
      lines.append("import UIKit")
    }
    lines += [
      "", "// swiftui-registry preset \(code)", "// \(url(code))",
      "// Written by `python3 Scripts/preset.py apply`. Edit freely; `preset.py resolve` reads it back into a code.",
      "", "extension RegistryTheme {",
      "    /// Apply once at the scene root: `ContentView().registryTheme(.app)`.",
      "    static let app = \(body[0])",
    ]
    lines += body.dropFirst().map { "    " + $0 }
    return (lines + ["}", ""]).joined(separator: "\n")
  }
  static func captures(_ pattern: String, _ text: String) -> [[String]] {
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
    return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).map { match in
      (1..<match.numberOfRanges).map {
        Range(match.range(at: $0), in: text).map { String(text[$0]) } ?? ""
      }
    }
  }
  public static func parseSwift(_ text: String, base: JSON = defaultTuning) throws -> JSON {
    guard text.contains("RegistryTheme(") else {
      throw RegistryError("no RegistryTheme( initializer found")
    }
    var tuning = base
    let flat = text.replacingOccurrences(of: "\n", with: " ")
    let channels = "red:\\s*([0-9.]+),\\s*green:\\s*([0-9.]+),\\s*blue:\\s*([0-9.]+)"
    let rgbs = captures("(?:UI)?Color\\(" + channels, flat)
    func hexChannels(_ values: [String]) -> JSON {
      let channels = values.map {
        max(0, min(255, Int(((Double($0) ?? 0) * 255).rounded(.toNearestOrEven))))
      }
      return .string(hex((channels[0] << 16) | (channels[1] << 8) | channels[2]))
    }
    if flat.contains("accent: Color(uiColor: UIColor {") && rgbs.count >= 2 {
      tuning["accent"] = "custom"
      tuning["customAccentDark"] = hexChannels(rgbs[0])
      tuning["customAccent"] = hexChannels(rgbs[1])
    } else if let word = captures("accent:\\s*\\.([a-zA-Z]+)", flat).first?.first {
      let accent =
        [
          "primary": "ink", "graphite": "ink", "rose": "pink", "emerald": "green",
          "amber": "yellow",
        ][word] ?? word
      guard accents.contains(accent), accent != "custom" else {
        throw RegistryError("unknown accent .\(word)")
      }
      tuning["accent"] = .string(accent)
      var object = tuning.object!
      object.removeValue(forKey: "customAccent")
      object.removeValue(forKey: "customAccentDark")
      tuning = .object(object)
    } else if let values = captures("accent:\\s*Color\\(" + channels, flat).first {
      tuning["accent"] = "custom"
      tuning["customAccent"] = hexChannels(values)
      tuning["customAccentDark"] = .null
    }
    if flat.contains("onAccent: .black") {
      tuning["darkLabelOnAccent"] = true
    } else if flat.contains("onAccent: .white") {
      tuning["darkLabelOnAccent"] = false
    }
    for key in ["surface", "border"] {
      if let value = captures("\\b\(key):\\s*\\.primary\\.opacity\\(([0-9.]+)\\)", flat).first?
        .first, let number = Double(value)
      {
        tuning[key + "Opacity"] = .number(number)
      }
    }
    for field in fields where field.key != "surfaceOpacity" && field.key != "borderOpacity" {
      if let value = captures("\\b\(field.key):\\s*([0-9]+(?:\\.[0-9]+)?)", flat).first?.first,
        let number = Double(value)
      {
        tuning[field.key] = .number(number)
      }
    }
    return tuning
  }
  public static func resolveFile(_ path: String) throws -> String {
    @Dependency(\.registryFileSystem) var fs
    let target = fs.isDirectory(path) ? path + "/" + themeFileName : path
    guard fs.isFile(target) else { throw RegistryError("no theme file at \(target)") }
    return try encode(parseSwift(String(decoding: fs.read(target), as: UTF8.self)))
  }
  @discardableResult public static func apply(
    _ code: String, destination: String, force: Bool = false
  ) throws -> String {
    @Dependency(\.registryFileSystem) var fs
    guard let tuning = decode(code) else { throw RegistryError("invalid preset code: \(code)") }
    let target = destination + "/" + themeFileName
    if fs.exists(target) && !force {
      let existing = String(decoding: try fs.read(target), as: UTF8.self)
      let header = captures("(?m)^// swiftui-registry preset (\\S+)$", existing).first?.first
      let written = header.flatMap { isCode($0) ? $0 : nil }
      let current = try? encode(parseSwift(existing))
      if written == nil || current != written {
        throw RegistryError(
          "\(target) was edited since it was written (it resolves to \(current ?? "no theme"), its header says \(written ?? "nothing")); pass --force to replace it"
        )
      }
    }
    try fs.createDirectory(destination)
    try fs.write(Data(themeFile(tuning, code: code).utf8), to: target)
    return target
  }
  public static func description(_ code: String, json: Bool = false) throws -> String {
    guard let tuning = decode(code) else { throw RegistryError("invalid preset code: \(code)") }
    let keys =
      ["accent", "darkLabelOnAccent"] + fields.map(\.key)
      + (tuning["accent"] == "custom" ? ["customAccent", "customAccentDark"] : [])
    func value(_ key: String) -> String {
      if let number = tuning[key].number { return String(number) }
      return tuning[key].rendered()
    }
    if json {
      let body = keys.map { "    \"\($0)\": \(value($0))" }.joined(separator: ",\n")
      return
        "{\n  \"code\": \"\(code)\",\n  \"version\": \"a\",\n  \"tuning\": {\n\(body)\n  },\n  \"swift\": \(try JSON.string(swiftSource(tuning)).rendered()),\n  \"url\": \(JSON.string(url(code)).rendered())\n}"
    }
    func row(_ key: String, _ value: String) -> String {
      "  " + key + String(repeating: " ", count: max(0, 26 - key.count)) + value
    }
    var lines = ["Preset", row("code", code), row("version", "a")]
    for key in keys {
      lines.append(row(key, tuning[key] == .null ? "none" : tuning[key].string ?? value(key)))
    }
    lines += [row("url", url(code)), "", try swiftSource(tuning)]
    return lines.joined(separator: "\n")
  }
}
