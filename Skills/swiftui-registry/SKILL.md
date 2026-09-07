---
name: swiftui-registry
description: Consume the source-owned SwiftUI registry from an app with the swiftui-registry tool: search, describe, plan, install, compose, diff, and update items, and drive the same engine over MCP.
metadata:
  short-description: Install and own SwiftUI registry items in a consuming app.
---

# SwiftUI Registry

## Goal

Add SwiftUI product UI to an app by copying understandable Swift source you own,
not by taking a framework dependency. The `swiftui-registry` tool searches a
local catalog, prints the exact install plan, copies the source with a receipt,
and audits or merges later change.

This skill answers two of the recorded iOS design-system pain points
(`docs/component-roadmap.md`, D8; `docs/mango.md`, Goal):

- Agent drift, three "add a settings screen" prompts producing three button
  styles: the item `usage` snippets, the `swiftui-registry mcp` server, and this
  skill hand an agent what the app already decided, so you compose through a
  fixed public API instead of inventing one (`docs/registry-spec.md`, Agent usage).
- Maintenance risk, the design-system package that goes unmaintained: source
  ownership with a receipt, a narrow foundations package pinned `upToNextMinor`
  from `0.1.0`, and `--diff` and `--update` for auditing later change
  (`docs/philosophy.md`, "Source ownership where change is expected";
  `docs/architecture.md`, Installation behavior and Update policy).

## Quick start

1. Install the tool: `brew install mangobyte-dev/tap/swiftui-registry`. From a
   clone of the registry, `swift run swiftui-registry <command>` runs the same
   tool against that clone.
2. Find an item: `swiftui-registry search activity --kind block --format names`.
3. Read it before installing: `swiftui-registry describe activity-feed`.
4. Preview the install without writing: `swiftui-registry install activity-feed --destination path/to/YourTarget/Components --plan`.
5. Install: `swiftui-registry install activity-feed --destination path/to/YourTarget/Components`.
6. Add the package requirement the installer prints, then make the destination
   folder a member of your build target and compose through the item's public
   API.

The installer never edits `.xcodeproj`, adds package dependencies, or hosts
content (`docs/architecture.md`, Installation behavior). It prints one package
line you act on, for example:

```text
add package https://github.com/mangobyte-dev/swiftui-ui-registry.git (from 0.1.0 up to the next minor version) and link product SwiftUIRegistryFoundations
```

## API interface

- Foundations public API (theme, metrics, presets, root modifiers): `references/interface/SwiftUIRegistryFoundations.swiftinterface`
- The catalog, items by kind with one-line descriptions: `references/catalog.md`
- Every item's call-site `usage` snippet, quoted from its canonical source: `references/usage.md`

Quote every registry API from these files, never from memory: API hallucination
is unsolved (`docs/component-roadmap.md`, D6).

## How to find an item

The command's why: search is local, deterministic, and JSON-first, so an agent
gets what it needs before installing without a model, account, or hosted
registry (`docs/architecture.md`, Discovery policy).

1. Search by free text plus optional filters:

   ```sh
   swiftui-registry search nutrition dashboard --kind block --platform iOS --target-version 26.0
   ```

2. Read the fields you need from the JSON: `name`, `kind`, `version`,
   `registryDependencies`, `packageDependencies`, `platforms`, `accessibility`,
   `preview`, and the `score`.
3. For a bare list of names, add `--format names`; `--format json` (the default)
   returns the full records.

- **DO** pass every term you know; every query term must match indexed metadata
  (name, alias, tag, description), so extra terms narrow the result.
- **DO** filter with `--kind component|block|flow|recipe`, `--platform iOS`, and
  `--target-version X.Y` to drop items your floor cannot use.
- **DO NOT** browse the source tree to discover items; `references/catalog.md`
  is the index and search is the query path.

## How to read an item

The command's why: read the usage snippet, accessibility notes, dependency
closure, and canonical source before installing, so you compose the API the item
actually declares (`docs/registry-spec.md`, Agent usage, step 3).

1. Print the item:

   ```sh
   swiftui-registry describe badge
   ```

   Text output leads with the name, kind, and version, the description, the
   `Usage:` snippet, the accessibility notes, the install order, the package
   requirements, and the file targets:

   ```text
   badge (component 0.3.1)
   Applies primary, secondary, outline, positive, and destructive badge treatments to native Text and Label content.

   Usage:
     Text("New")
         .registryBadge()

     Label("Completed", systemImage: "checkmark.circle.fill")
         .registryBadge(.positive)
   ```

2. Append `--source` to print each installable file's canonical content under
   the file targets.
3. Use `--format json` to get the same payload the MCP `describe_item` tool
   returns, for programmatic reading.

- **DO** read a `recipe` with `describe` too; it reports native guidance instead
  of an install closure, because nothing installs (`docs/registry-spec.md`, Item
  value gate).
- **DO NOT** assume a signature from the item name; the `Usage:` block and
  `references/usage.md` carry the real public API.

## How to plan and install into a destination

The command's why: both inspection flags are read-only and write nothing, so an
agent previews and audits before touching the destination
(`docs/architecture.md`, Installation behavior, "Two read-only modes").

1. Preview the resolution and every target write without writing:

   ```sh
   swiftui-registry install finance-overview --destination path/to/YourTarget/Components --plan
   ```

   `--plan` prints the ordered dependency closure with versions and kinds, each
   target write with its status (`new`, `up-to-date`,
   `modified-would-require-force`, `would-merge`), the package requirements,
   collisions, and the manual integration steps.

2. Install for real:

   ```sh
   swiftui-registry install finance-overview --destination path/to/YourTarget/Components
   ```

   The installer resolves the closure depth first (here `metric-card`,
   `transaction-row`, and `empty` before `finance-overview`), copies exact
   source, and writes `.swiftui-registry/receipt.json` plus non-Swift base
   snapshots inside the destination.

3. Point `--destination` at a folder inside the consuming target's sources so
   the copied files are members of that build target; the installer does not set
   target membership.

- **DO** use `--destination` paths inside your target; the installer copies
  source only, it does not mutate the project file.
- **DO** pass `--force` only to replace modified owned source; a repeated install
  otherwise accepts only source that still matches its receipt.
- **DO NOT** install a `recipe`: it exits with code 2 and prints its native
  guidance; copy the snippet from `describe` or `references/usage.md` instead
  (`docs/registry-spec.md`, Item value gate).

## How to compose through the public initializer

The why: a registry view's initializer carries what it is (content, bindings,
actions, required accessibility input); a presentation choice the view owns is a
`registry`-prefixed method applied before generic modifiers
(`docs/architecture.md`, View boundaries). Compose the declared API rather than
rewriting the item from memory (`docs/registry-spec.md`, Agent usage, step 6).

A component treatment applies to a native control, quoted from the `badge` item:

```swift
Text("New")
    .registryBadge()

Label("Completed", systemImage: "checkmark.circle.fill")
    .registryBadge(.positive)
```

A block composes components and takes prepared values, bindings, and actions,
quoted from the `activity-feed` item:

```swift
ActivityFeed(
    "Activity",
    notice: ActivityNotice("Card delivery delayed", message: Text("Arrives Thursday.")),
    onDismissNotice: { },
    items: [
        ActivityItem(
            id: "bakery",
            title: Text("Mishmash Bakery"),
            detail: Text("Card payment of KWD 8.750"),
            timestamp: Text("09:41"),
            initials: "MB",
            senderName: Text("Mishmash Bakery"),
            isUnread: true
        )
    ],
    earlierItems: [],
    isLoading: false,
    onSelect: { id in }
)
```

A recipe installs nothing; you copy its native snippet, quoted from the `sheet`
recipe:

```swift
@State private var isShowingDetails = false

NavigationStack {
    List {
        LabeledContent("Merchant", value: "Mishmash Bakery")
        LabeledContent("Amount", value: "KWD 8.750")
    }
    .navigationTitle("Transaction")
    .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Details", systemImage: "sidebar.trailing") {
                isShowingDetails.toggle()
            }
            .accessibilityLabel("Toggle details")
        }
    }
    .inspector(isPresented: $isShowingDetails) {
        List {
            LabeledContent("Category", value: "Dining")
            LabeledContent("Card", value: "Visa 4321")
            LabeledContent("Status", value: "Cleared")
        }
        .inspectorColumnWidth(min: 240, ideal: 280, max: 360)
    }
}
```

- **DO** keep caller-controlled state with the caller through bindings; a block
  does not own a `ScrollView`, navigation container, or maximum width
  (`docs/architecture.md`, View boundaries).
- **DO** provide required accessibility input the view cannot derive, such as an
  `avatar`'s label (`docs/philosophy.md`, "Accessible and adaptive by default").
- **DO NOT** copy a `usage` snippet's placeholder values into shipping code; they
  show the API shape, not your data.

## How to audit and update owned copies

The why: copied source stays consumer-owned; the updater never silently resolves
a conflict or replaces a customized file (`docs/architecture.md`, Update policy).

1. See what an existing destination holds, from its receipt alone:

   ```sh
   swiftui-registry info --destination path/to/YourTarget/Components
   ```

   `info` marks each owned file up-to-date, modified, or missing against the
   digest recorded at install time, and exits 2 when the destination holds no
   receipt.

2. Before taking upstream change, diff your owned copy against canonical:

   ```sh
   swiftui-registry install finance-overview --destination path/to/YourTarget/Components --diff
   ```

   `--diff` prints a unified diff per receipt-backed file, exits 0 on parity and
   1 on differences, and requires an existing receipt.

3. Take upstream change with a three-way merge:

   ```sh
   swiftui-registry install finance-overview --destination path/to/YourTarget/Components --update
   ```

   Unmodified files receive the registry version, local-only edits stay, disjoint
   edits merge with `git merge-file`, and overlapping edits leave the file
   unchanged and write a `.merge` artifact under `.swiftui-registry/conflicts/`.

- **DO** run `--diff` before `--update` to see exactly what local customization
  is at stake.
- **DO** resolve any `.swiftui-registry/conflicts/<id>.merge` artifact by hand;
  the updater preflights the whole closure so one conflict cannot leave a partial
  update.
- **DO NOT** hand-edit `.swiftui-registry/receipt.json` or the `bases/*.base`
  snapshots; they are the provenance the diff and merge depend on.

## How to use the MCP server

The why: `swiftui-registry mcp` is a thin stdio adapter over the same engine, so
an agent inside a consuming app can search, plan, and install without leaving its
editor (`docs/architecture.md`, Discovery policy).

1. Register the Homebrew-installed binary in the MCP client, in its server
   config (for example an `.mcp.json`):

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

   Add `"--registry", "/path/to/clone"` to `args` to serve a checkout instead of
   the pinned snapshot.

2. Call the seven tools, each the counterpart of a CLI command over newline-
   delimited JSON-RPC on stdin and stdout (`docs/registry-spec.md`, Agent usage):
   `search_items`, `describe_item`, `plan_install`, `diff_item`, `install_item`,
   and the preset tools `describe_preset` and `apply_preset`.

- **DO** rely on the tool hints: the read-only tools carry `readOnlyHint` and
  `install_item` carries `destructiveHint`, so clients prompt before it writes.
- **DO** expect the server to reload validated registry metadata on every tool
  call, so edits to a clone are visible without a restart.
- **DO NOT** parse the server's log lines as data; logs go to stderr only and
  stdout stays clean JSON-RPC.

## How to work from a clone or the snapshot

The why: the tool finds the registry in a fixed order so the same command works
inside a checkout and from an installed binary (`docs/cli-migration.md`,
Resolution and distribution).

1. Resolution order: `--registry <path>` wins first, then a clone enclosing the
   working directory (the nearest ancestor holding `Registry/registry.json`),
   then the cached snapshot of the pinned release under
   `~/Library/Caches/swiftui-registry/`.
2. From inside a clone, run `swift run swiftui-registry <command>`; a release
   build lives at `.build/release/swiftui-registry`.
3. From any directory with the Homebrew binary, the tool fetches the pinned
   snapshot from the published tag on first use and reuses it.

- **DO** pass `--registry /absolute/path/to/clone` to point an installed binary
  at a checkout.
- **DO** pass `--refresh` to download the pinned snapshot again; it touches only
  the cache and the update stamp, never owned source, and is separate from
  `--force`.
- **DO NOT** expect `--refresh` to affect a `--registry` override or an enclosing
  clone; neither is served from the snapshot.
