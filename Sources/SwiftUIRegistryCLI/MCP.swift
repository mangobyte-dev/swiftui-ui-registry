import ArgumentParser
import RegistryKit

struct MCP: ParsableCommand {
  @OptionGroup var options: RegistryOptions
  func run() throws { try refusal { try MCPServer(root: options.root()).serve() } }
}
