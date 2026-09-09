# CLI

`swiftui-registry`: one binary, no dependencies. `brew install mangobyte-dev/tap/swiftui-registry`, or `swift run swiftui-registry <command>` from clone.

Registry source:

- `--registry <path>`: that checkout.
- Inside clone: enclosing one.
- Elsewhere: cached snapshot; `--refresh` rechecks tap.

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

Local, deterministic, JSON-first, no model/account/hosted service. Results: closure, package/accessibility/compatibility, previews.

```sh
swiftui-registry search nutrition dashboard --kind block --platform iOS --target-version 26.0
swiftui-registry search activity --kind block --format names
```

## describe

Prints item: name, kind, version, description, usage, accessibility notes; installables: closure, requirement, targets. `--source`: content; `--format json`: MCP `describe_item` payload; recipes: native guidance.

```sh
swiftui-registry describe activity-feed
swiftui-registry describe button --source
```

## install

```text
USAGE: swiftui-registry install [--registry <registry>] [--refresh] <item> --destination <destination> [--force] [--update] [--plan] [--diff]
```

- `--plan`: dry run: closure, status (`new`/`up-to-date`/`modified-would-require-force`/`would-merge`), requirement, collisions, steps.
- Default: copies closure, writes `.swiftui-registry/receipt.json` + non-Swift base snapshots, prints requirement; repeat needs matching receipt.
- `--diff`: unified diff vs registry, exit 1 on difference, needs receipt.
- `--update`: unmodified takes registry, edits stay, disjoint merges via `git merge-file`, overlapping keeps file, writes `.merge` under `.swiftui-registry/conflicts/`.
- `--force` replaces modified source, skips cache.
- Recipe: installs nothing, exit 2.

Checks tap daily, prints upgrade if newer; failures silent.

## info

Reads receipt, lists items, marks files up-to-date/modified/missing vs install-time digests. Never touches registry; exits 2 without one.

```sh
swiftui-registry info --destination Sources/App/Components
```

## preset

Preset code: one `RegistryTheme` string, read/written by tool, Showcase, website, MCP.

```sh
swiftui-registry preset decode a13GkaOXWwIF          # the knobs, the Swift, the website URL (--json for the payload)
swiftui-registry preset url a13GkaOXWwIF             # the Create page for the code
swiftui-registry preset apply a74hGF01CVunaG0vzZJG --destination path/to/YourApp   # writes RegistryTheme+App.swift
swiftui-registry preset resolve path/to/YourApp/RegistryTheme+App.swift          # an edited theme file back into a code
swiftui-registry preset random                        # a code to start from
```

Theme file: not registry item, no receipt; apply via `.registryTheme(.app)`.

## validate and generate

`validate`: structural check over catalog, exits 0/1 with report; scopes to items, closures.

`generate catalog`/`showcase-manifest`/`site-data`/`item-tokens`: files committed, synced with metadata: site, catalog, Showcase manifest, token map.

## mcp

`swiftui-registry mcp` serves engine over stdio; see [MCP server](/docs/mcp/).
