<!-- Reference pointer for the swiftui-registry-authoring skill. -->

# Authoring rules

The rules an item must satisfy (the placement rule for presentation choices, the
value gate, semantic tokens, accessibility input, previews, the generated-output
contract, and the single structural validator) live in one place and are not
copied here so this skill never drifts from them:

- `AGENTS.md`, the "Rules" and "Boundaries" sections (repository root)
- `docs/philosophy.md` (why) and `docs/architecture.md` (how)
- `docs/registry-spec.md` (the data and installer contract, including the value gate)

Read `AGENTS.md` in full before authoring. `Sources/RegistryKit/Validation.swift`
is the single structural validator; a structural rule that is not in it is not
enforced.
