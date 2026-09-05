# Contributing

Start with `docs/philosophy.md` and `docs/architecture.md`

For a registry item:

1. Solve a product-composition problem above Apple's native controls
2. Keep inputs architecture-neutral and localizable
3. Add a focused preview covering realistic content and large-text behavior
4. Add item metadata with a semantic version, exact files, registry dependencies, platform floor, and accessibility notes
5. Install the item into `Examples/Showcase`, register its demo in `ItemDemos.swift`, and compile it at the deployment floor
6. Add dependency-resolution and search coverage when introducing a new item
7. Capture the item with `python3 Scripts/capture_previews.py <name>`, then regenerate the catalog, the Showcase manifest, and the site data
8. Review the regular and accessibility-size states before changing a visual reference

Avoid broad refactors, new dependencies, and generic control replacements in component changes
