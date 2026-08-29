# Registry specification version 1

The canonical schema is `Registry/schema.json`. JSON is used because it is inspectable, widely supported, and does not require a Swift tool to discover an item

## Registry index

`Registry/registry.json` contains:

- `schemaVersion`: currently `1`
- `name`: registry name
- `items`: relative paths to item documents

## Item fields

- `schemaVersion`: schema compatibility number
- `version`: semantic item version recorded as provenance
- `name`: deterministic kebab-case installation name
- `kind`: `component`, `block`, or `flow`
- `description`: one sentence describing product purpose
- `files`: canonical source path and consumer target filename
- `registryDependencies`: other item names resolved before this item
- `packageDependencies`: Swift package, product, and version requirement the consumer must provide
- `platforms`: declared Apple platform and minimum version
- `tags`: discovery terms, not API behavior
- `accessibility`: concrete behavior and known requirements
- `preview`: source preview name and optional screenshot paths

## Resolution

Resolution is depth first and deterministic in dependency declaration order. Each item is installed once. Unknown items, dependency cycles, missing source, duplicate targets, unsafe paths, untracked collisions, and modified receipt-backed targets fail loudly

## File ownership

A target path is relative to the destination selected by the consumer. Version 1 does not prescribe groups, targets, module names, or project-file mutation

After copying, the consumer owns the target file. The registry remains the provenance source, not a remote authority over local edits

The installer stores provenance under `.swiftui-registry/` in the selected destination. `receipt.json` records item versions, dependency declarations, content digests, targets, and base snapshot paths. Base and conflict artifacts use non-Swift extensions so they cannot become duplicate declarations in a buildable source folder

## Package dependencies

The prototype reports package dependencies through metadata but does not install them. This avoids unsafe `.xcodeproj` mutation and keeps dependency approval with the consuming team

## Evolution rules

- Additive optional fields may be introduced within schema version 1
- Removing or changing field meaning requires a new schema version
- Item API evolution does not silently overwrite copied code
- Receipts identify exact source and installed content, not only an item name
- Updating a modified file requires a clean three-way merge or explicit conflict review

## Agent usage

An agent should:

1. Search item metadata by name, kind, tags, platform, and minimum version with `Scripts/search.py`
2. Read the dependency closure and package requirements
3. Inspect preview and accessibility notes
4. Install the item sources
5. Compose through the public initializer rather than rewriting the item from memory
6. Compile the consumer at its deployment floor
