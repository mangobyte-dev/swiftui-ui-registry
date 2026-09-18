import Dependencies
import Foundation

/// The `describe_item` payload shared by the MCP `describe_item` tool and the CLI `describe`
/// command. Item metadata keeps the source document's field order; an installable item also
/// carries the resolved install order, package requirements, and canonical file source, while a
/// recipe stops at its metadata and `installs: false`.
public func describeItem(_ name: String, registry: Registry, fs: FileSystem, root: String)
  throws -> OrderedJSON
{
  guard let item = registry.items[name] else {
    throw RegistryError("Unknown registry item: \(name)")
  }
  // Preserve nested platform metadata order from the item document too.
  let index = try JSON.read(fs.read(root + "/Registry/registry.json"))
  var original: OrderedJSON = [:]
  for path in index["items"].strings {
    let data = try fs.read(root + "/Registry/" + path)
    if try JSON.read(data)["name"].text == name {
      original = try OrderedJSON.read(data)
      break
    }
  }
  var described = OrderedJSON.object(
    [
      "name", "kind", "version", "description", "usage", "docs", "tags", "aliases", "platforms",
      "accessibility", "registryDependencies",
    ].map { ($0, original[$0]) })
  if item["kind"] == "recipe" {
    described["installs"] = false
    return described
  }
  described["installs"] = true
  described["installOrder"] = .array(try registry.resolve(name).map(OrderedJSON.string))
  described["packageRequirements"] = .array(
    try registry.packageRequirements(name).map(packageDescription))
  let sources = try (item["files"].array ?? []).map { file in
    (file, try readText(fs, root + "/Registry/" + file["source"].text))
  }
  described["signatures"] = .array(
    sources.flatMap { publicSignatures(in: $0.1) }.map(OrderedJSON.string))
  described["files"] = .array(
    sources.map { file, content in
      [
        "source": OrderedJSON(file["source"]), "target": OrderedJSON(file["target"]),
        "content": .string(content),
      ]
    })
  return described
}

/// The public initializers, functions, and static members a source file declares, each on one
/// line up to its body, so a composer sees parameter labels and types without opening the file.
func publicSignatures(in source: String) -> [String] {
  let starts = [
    "public init(", "public init<", "public func ", "public static var ", "public static let ",
    "public static func ", "public mutating func ",
  ]
  // Members of a `public extension` are public without the keyword; the extension closes at
  // the first brace back in column zero.
  let extensionStarts = ["init(", "init<", "func ", "static var ", "static let ", "static func "]
  var signatures: [String] = []
  var current = ""
  var open = false
  var depth = 0
  var inPublicExtension = false
  for rawLine in source.components(separatedBy: "\n") {
    let line = rawLine.trimmingCharacters(in: .whitespaces)
    if rawLine.hasPrefix("public extension ") { inPublicExtension = true }
    if rawLine == "}" { inPublicExtension = false }
    if !open {
      let matches =
        starts.contains(where: { line.hasPrefix($0) })
        || (inPublicExtension && extensionStarts.contains(where: { line.hasPrefix($0) }))
      // A style's makeBody is the protocol's, never called by a composer.
      guard matches, !line.contains("func makeBody(") else { continue }
      open = true
      depth = 0
      current = ""
    }
    // A declaration ends at its body's brace or, for a stored static, at its value; both sit
    // outside every parenthesis, where a default value's `=` never is.
    var ended = false
    var piece = ""
    let characters = Array(line)
    for (index, character) in characters.enumerated() {
      if character == "(" || character == "[" { depth += 1 }
      if character == ")" || character == "]" { depth -= 1 }
      if depth == 0 {
        if character == "{" {
          ended = true
          break
        }
        let previous = index > 0 ? characters[index - 1] : " "
        let next = index + 1 < characters.count ? characters[index + 1] : " "
        if character == "=", !"=!<>".contains(previous), next != "=" {
          ended = true
          break
        }
      }
      piece.append(character)
    }
    let trimmed = piece.trimmingCharacters(in: .whitespaces)
    current += (current.isEmpty || trimmed.isEmpty ? "" : " ") + trimmed
    if ended {
      signatures.append(
        current.replacingOccurrences(of: "( ", with: "(").replacingOccurrences(of: " )", with: ")"))
      open = false
    }
  }
  return signatures
}
