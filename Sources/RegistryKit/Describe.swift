import Dependencies
import Foundation

/// The `describe_item` payload shared by the MCP `describe_item` tool and the CLI `describe`
/// command. Item metadata keeps the source document's field order; an installable item also
/// carries the resolved install order, package requirements, and canonical file source, while a
/// recipe stops at its metadata and `installs: false`.
public func describeItem(_ name: String, registry: Registry, fs: any FileSystem, root: String)
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
  described["files"] = .array(
    try (item["files"].array ?? []).map { file in
      [
        "source": OrderedJSON(file["source"]), "target": OrderedJSON(file["target"]),
        "content": .string(try readText(fs, root + "/Registry/" + file["source"].text)),
      ]
    })
  return described
}
