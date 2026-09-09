# CLI

`swiftui-registry` is one binary with no runtime dependencies. Install it with `brew install mangobyte-dev/tap/swiftui-registry`, or run `swift run swiftui-registry <command>` from a clone.

Every command works from any directory:

- With `--registry /path/to/clone`, it reads that checkout.
- Inside a clone, it reads the enclosing one.
- Anywhere else, it fetches the registry snapshot of its own release tag on first use and caches it. `--refresh` fetches again and checks the tap for a newer release.

```text
USAGE: swiftui-registry <subcommand>

SUBCOMMANDS:
  validate
  search
  describe                Print an item's metadata, usage, dependency closure,
                          and file targets.
  install
  info                    Report the installed items and file status in a
                          destination from its receipt.
  preset
  generate
  mcp
```

## search

The search command is local, deterministic, and JSON-first. Results carry these fields:

- dependency closure inputs
- package requirements
- accessibility notes
- preview paths
- compatibility metadata

No model, account, or hosted service is involved.

```sh
swiftui-registry search nutrition dashboard --kind block --platform iOS --target-version 26.0
swiftui-registry search activity --kind block --format names
```

## describe

describe prints an item before you install it. It prints these fields:

- name, kind, version, description
- the call-site usage snippet
- the accessibility notes
- for an installable item: the ordered install closure, the package requirement, and the file targets

`--source` appends each file's canonical content. `--format json` prints the payload the MCP `describe_item` tool returns. A recipe reports its native guidance instead of an install closure.

```sh
swiftui-registry describe activity-feed
swiftui-registry describe button --source
```

## install

```text
USAGE: swiftui-registry install [--registry <registry>] [--refresh] <item> --destination <destination> [--force] [--update] [--plan] [--diff]
```

- `--plan` resolves the item like a real install and writes nothing. It prints the ordered closure, every target write with its status (`new`, `up-to-date`, `modified-would-require-force`, `would-merge`), the package requirement, preflight collisions, and the manual steps.
- A plain install copies the closure, writes `.swiftui-registry/receipt.json` and non-Swift base snapshots inside the destination, and prints the requirement. A repeated install is accepted only when the existing source still matches its receipt.
- `--diff` prints a unified diff of each owned file against the registry source and exits 1 when they differ. It needs a receipt.
- `--update` is content-based: unmodified files take the registry version, local edits stay, disjoint edits merge with `git merge-file`, and overlapping edits keep the owned file and write a `.merge` artifact under `.swiftui-registry/conflicts/`.
- `--force` replaces modified owned source. It never touches the registry cache.
- A recipe installs nothing: the command prints its guidance and exits with code 2.

After an install, the tool asks the Homebrew tap for a newer release at most once a day. It prints the upgrade command when a release is newer than the running tool. A failed check is silent.

## info

info reads the receipt in a destination. It reports each installed item, and marks its owned files up-to-date, modified, or missing against the digests recorded at install time. It never touches the registry. It exits 2 when the destination holds no receipt.

```sh
swiftui-registry info --destination Sources/App/Components
```

## preset

A preset code is a `RegistryTheme` as one short string. The tool, the Showcase, the website, and the MCP server all read and write it.

```sh
swiftui-registry preset decode a13GkaOXWwIF          # the knobs, the Swift, the website URL (--json for the payload)
swiftui-registry preset url a13GkaOXWwIF             # the Create page for the code
swiftui-registry preset apply a74hGF01CVunaG0vzZJG --destination path/to/YourApp   # writes RegistryTheme+App.swift
swiftui-registry preset resolve path/to/YourApp/RegistryTheme+App.swift          # an edited theme file back into a code
swiftui-registry preset random                        # a code to start from
```

The theme file is not a registry item and carries no receipt. The app applies it with `.registryTheme(.app)`.

## validate and generate

`validate` runs the one structural validator over the catalog. It exits 0 or 1 with a readable report. You can scope it to named items and their closures.

`generate catalog`, `generate showcase-manifest`, `generate site-data`, and `generate item-tokens` write the derived files a maintainer commits. They keep this site, the markdown catalog, the Showcase manifest, and the design surface's token map in step with the metadata.

## mcp

`swiftui-registry mcp` serves the same engine over stdio. See the [MCP server](/docs/mcp/) page.
