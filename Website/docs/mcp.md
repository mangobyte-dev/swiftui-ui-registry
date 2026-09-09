# MCP server

`swiftui-registry mcp` exposes the registry's operations as tools over stdio, so an agent uses the same engine a person uses on the command line: search, describe, plan, diff, install, and the preset tools. Register the Homebrew-installed binary in your MCP client; in Claude Code's `.mcp.json`:

```json
{
  "mcpServers": {
    "swiftui-registry": {
      "command": "swiftui-registry",
      "args": ["mcp"]
    }
  }
}
```

Add `"--registry", "/path/to/clone"` to the arguments to serve a checkout instead of the pinned snapshot.

## What the tools do

- The read-only tools carry `readOnlyHint`: search returns the same ranked results as the command, `describe_item` returns the payload `describe --format json` prints, the plan tool returns the install plan without writing, and the diff tool reports owned edits against the registry source.
- `install_item` carries `destructiveHint`, so a client prompts before it writes. It resolves the closure, copies the source, and writes the receipt exactly as the command does; it refuses a modified owned file without the force flag, as the command does.
- `describe_preset` and `apply_preset` read and write preset codes, so an agent can push a theme onto a project from a code.
- A recipe reports its native guidance and installs nothing.

## Ground truth for an agent

An agent that composes with the registry should quote from the tool, never from memory: `describe <item>` for an item's usage snippet, `install --plan` for the requirement to add, and `preset decode` for a theme's knobs. The three skills under `Skills/` in the repository package this workflow in the Point-Free skill format for consuming, theming, and authoring the registry.
