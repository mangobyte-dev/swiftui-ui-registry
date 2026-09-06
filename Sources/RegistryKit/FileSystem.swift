import Dependencies
import Foundation

public protocol FileSystem: Sendable {
  var currentDirectory: String { get }
  func resolve(_ path: String) -> String
  func exists(_ path: String) -> Bool
  func isFile(_ path: String) -> Bool
  func isDirectory(_ path: String) -> Bool
  func read(_ path: String) throws -> Data
  func write(_ data: Data, to path: String) throws
  func createDirectory(_ path: String) throws
  func remove(_ path: String) throws
  func replace(_ source: String, _ target: String) throws
  func children(_ path: String) throws -> [String]
}

public struct LocalFileSystem: FileSystem {
  public init() {}
  public var currentDirectory: String { FileManager.default.currentDirectoryPath }
  public func resolve(_ path: String) -> String {
    if let resolved = realpath(path, nil) {
      defer { free(resolved) }
      return String(cString: resolved)
    }
    func walk(_ path: String, depth: Int) -> String {
      let absolute = path.hasPrefix("/") ? path : currentDirectory + "/" + path
      var parts: [String] = []
      for part in absolute.split(separator: "/") {
        if part == "." { continue }
        if part == ".." {
          if !parts.isEmpty { parts.removeLast() }
          continue
        }
        let parent = "/" + parts.joined(separator: "/")
        parts.append(String(part))
        if depth < 40,
          let link = try? FileManager.default.destinationOfSymbolicLink(
            atPath: "/" + parts.joined(separator: "/"))
        {
          let target = walk(link.hasPrefix("/") ? link : parent + "/" + link, depth: depth + 1)
          parts = target.split(separator: "/").map(String.init)
        }
      }
      return "/" + parts.joined(separator: "/")
    }
    return walk(path, depth: 0)
  }
  public func exists(_ path: String) -> Bool { FileManager.default.fileExists(atPath: path) }
  public func isDirectory(_ path: String) -> Bool {
    var flag = ObjCBool(false)
    return FileManager.default.fileExists(atPath: path, isDirectory: &flag) && flag.boolValue
  }
  public func isFile(_ path: String) -> Bool { exists(path) && !isDirectory(path) }
  public func read(_ path: String) throws -> Data {
    try Data(contentsOf: URL(fileURLWithPath: path))
  }
  public func write(_ data: Data, to path: String) throws {
    try data.write(to: URL(fileURLWithPath: path))
  }
  public func createDirectory(_ path: String) throws {
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
  }
  public func remove(_ path: String) throws {
    if exists(path) { try FileManager.default.removeItem(atPath: path) }
  }
  public func replace(_ source: String, _ target: String) throws {
    guard rename(source, target) == 0 else {
      throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
    }
  }
  public func children(_ path: String) throws -> [String] {
    try FileManager.default.contentsOfDirectory(atPath: path).sorted().map { path + "/" + $0 }
  }
}

private enum FileSystemKey: DependencyKey {
  static let liveValue: any FileSystem = LocalFileSystem()
}
extension DependencyValues {
  public var registryFileSystem: any FileSystem {
    get { self[FileSystemKey.self] }
    set { self[FileSystemKey.self] = newValue }
  }
}

public protocol RegistrySource: Sendable {
  func repositoryRoot(override: String?) throws -> String
}
public struct LocalRegistrySource: RegistrySource {
  public init() {}
  public func repositoryRoot(override: String?) throws -> String {
    @Dependency(\.registryFileSystem) var fs
    if let override { return fs.resolve(override) }
    var candidate = fs.resolve(fs.currentDirectory)
    while true {
      if fs.isFile(candidate + "/Registry/registry.json") { return candidate }
      let parent = (candidate as NSString).deletingLastPathComponent
      if candidate == parent { break }
      candidate = parent
    }
    throw RegistryError("No registry clone found; pass --registry <path>")
  }
}
private enum RegistrySourceKey: DependencyKey {
  static let liveValue: any RegistrySource = LocalRegistrySource()
}
extension DependencyValues {
  public var registrySource: any RegistrySource {
    get { self[RegistrySourceKey.self] }
    set { self[RegistrySourceKey.self] = newValue }
  }
}

func safeJoin(_ root: String, _ value: String, fs: any FileSystem) throws -> String {
  let parts = value.split(separator: "/")
  guard !value.isEmpty, !value.hasPrefix("/"), !parts.contains(".."),
    parts.contains(where: { $0 != "." })
  else {
    throw RegistryError("Unsafe registry path: \(value)")
  }
  let root = fs.resolve(root)
  let candidate = fs.resolve(root + "/" + value)
  guard candidate == root || candidate.hasPrefix(root + "/") else {
    throw RegistryError("Registry path escapes through a symbolic link: \(value)")
  }
  return candidate
}
