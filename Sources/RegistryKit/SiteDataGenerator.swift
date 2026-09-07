import Dependencies
import Foundation

public struct SiteDataGenerator {
  let registry: Registry
  let root: String
  @Dependency(\.registryFileSystem) var fs
  public static let outputPath = "Website/content/registry.json"
  public static let imagesPath = "Website/public/images"
  static let repositoryURL = "https://github.com/mangobyte-dev/swiftui-ui-registry"
  public init(root: String) throws {
    self.root = root
    registry = try Registry(root: root)
  }

  public func render() throws -> String {
    let items = try registry.items.keys.sorted().map { name -> OrderedJSON in
      let item = registry.items[name]!
      let recipe = item["kind"] == "recipe"
      let preview = item["preview"]
      let screenshots = preview["screenshots"].strings
      let source = item["files"].array?.first?["source"].string
      var result = OrderedJSON.fields(
        item, ["name", "kind", "version", "description", "usage", "docs", "tags"])
      result["aliases"] = OrderedJSON(item.object?["aliases"] ?? [])
      result["platforms"] = .array(
        (item["platforms"].array ?? []).map {
          .string("\($0["name"].text) \($0["minimumVersion"].text)+")
        })
      result["dependencies"] = OrderedJSON(item["registryDependencies"])
      result["installOrder"] = .array(
        try recipe
          ? []
          : registry.resolve(name).map {
            OrderedJSON.fields(registry.items[$0]!, ["name", "version"])
          })
      result["accessibility"] = OrderedJSON(item["accessibility"])
      result["sourcePath"] = source.map { .string("Registry/" + $0) } ?? nil
      result["sourceURL"] =
        source.map { .string(Self.repositoryURL + "/blob/main/Registry/" + $0) } ?? nil
      result["source"] =
        try source.map { .string(try readText(fs, root + "/Registry/" + $0)) } ?? nil
      result["previewName"] = OrderedJSON(preview["name"])
      result["screenshots"] = .object(
        ["light", "dark"].map { appearance in
          (
            appearance,
            screenshots.first { $0.hasSuffix("-\(appearance).png") }.map {
              .string("/images/items/" + ($0 as NSString).lastPathComponent)
            } ?? nil
          )
        })
      result["wideScreenshots"] = imagePaths(folder: "ipad", stem: name + "-ipad")
      result["requirements"] = .array(
        try recipe ? [] : registry.packageRequirements(name).map(packageDescription))
      return result
    }
    let presets: [(String, String, String)] = [
      ("System", "system", "Inherits the app tint. The default."),
      ("Graphite", "graphite", "Ink on paper: primary accent, background label."),
      ("Indigo", "indigo", "The Showcase's own accent."),
      ("Rose", "rose", "Warm and friendly."),
      ("Emerald", "emerald", "Growth and confirmation."),
      ("Amber", "amber", "A light accent that proves the on-accent token."),
    ]
    let output: OrderedJSON = [
      "name": .string(registry.name), "repositoryURL": .string(Self.repositoryURL),
      "counts": .object(
        ["component", "block", "recipe"].map { kind in
          (
            kind,
            OrderedJSON(
              .number(Double(registry.items.values.filter { $0["kind"].text == kind }.count)))
          )
        }),
      "items": .array(items),
      "presets": .array(
        presets.map { name, slug, blurb in
          [
            "name": .string(name), "slug": .string(slug), "blurb": .string(blurb),
            "screenshots": imagePaths(folder: "themes", stem: slug),
          ]
        }),
    ]
    return output.rendered(ascii: false) + "\n"
  }
  private func imagePaths(folder: String, stem: String) -> OrderedJSON {
    .object(
      ["light", "dark"].map { appearance in
        let file = "\(folder)/\(stem)-\(appearance).png"
        return (
          appearance, fs.isFile(root + "/docs/images/" + file) ? .string("/images/" + file) : nil
        )
      })
  }
  public func generate(output: String, images: String) throws -> Int {
    let text = try render()
    try fs.createDirectory(parentDirectory(output))
    try fs.write(Data(text.utf8), to: output)
    var count = 0
    for folder in ["items", "themes", "ipad", "comparison"] {
      let source = root + "/docs/images/" + folder
      let target = images + "/" + folder
      try fs.remove(target)
      if !fs.isDirectory(source) { continue }
      try fs.createDirectory(target)
      for image in try fs.children(source) where image.hasSuffix(".png") {
        try fs.write(fs.read(image), to: target + "/" + (image as NSString).lastPathComponent)
        count += 1
      }
    }
    return count
  }
}

func packageDescription(_ entry: JSON) -> OrderedJSON {
  [
    "instruction": .string(Registry.dependencyInstruction(entry)),
    "manifest": .string(Registry.dependencyManifest(entry).joined(separator: "\n")),
    "xcode": .string(Registry.dependencyXcode(entry)),
  ]
}

func readText(_ fs: any FileSystem, _ path: String) throws -> String {
  let data = try fs.read(path)
  guard let text = String(data: data, encoding: .utf8) else {
    throw RegistryError("Cannot decode UTF-8: \(path)")
  }
  return text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(
    of: "\r", with: "\n")
}
