# Handoff: after the Create page, preset codes, and the persistent tuning panel

Written 2026-09-05 at the end of the create session. State lives in `docs/component-roadmap.md` (Current state, Open deferrals, Backlog items 16 and 17, and the Audit section); this file is the brief, not a second home for state

---

I am Mo, the owner of SwiftUIRegistry. The registry now has its counterpart of shadcn's `/create`: preset codes that the website's Create page, the Showcase's tuning panel, `Scripts/preset.py`, and the MCP server all speak, and the tuning panel stays beside the catalog on device. Everything is committed and `main` is pushed (2026-09-05); the website is deployed to https://swiftui-registry.mangobytekw.workers.dev with the Create page live. The `0.1.0` tag is still local, so declared floors do not resolve until it is pushed. Read `AGENTS.md`, then Backlog items 16 and 17 and the Open deferrals in `docs/component-roadmap.md`

## What is waiting for me

1. Replace the two visual references from the final suite run's kept attachments, reviewed first, then re-run the suite. The reviewed candidates are at `/private/tmp/claude-501/-Users-developer-Projects-swiftui-cn/7db8cc48-cfcb-4ea2-8c09-ebfba8bf4c18/scratchpad/review-2026-09-05` (`auth-light.png`, `nutrition-light.png`, alongside the Amber preset captures and the Create page screenshot); the copy commands are listed under "Reference replacement" below. Until then `auth-light` (2.67 percent, stale since the audit) and `nutrition-light` (1.53 percent) fail their visual assertion because those blocks reach the accent strip; the other 17 UI tests and 7 Showcase unit tests pass
2. Decide the owner items in the Audit section's "Deferred, with the reason": the `button-group` item that renders as the stock capsule, the checkbox double dim, the bare dividers and the native button in the two Stage 1 blocks, the wash opacities, the preview guard convention, preview strings in consumer catalogs, and the bundle policy for package installs
3. Try the Create page and the panel yourself: `Website/` at `/create?preset=a13GkaOXWwIa` (Amber), then in the Showcase tap Tune in the strip, Import, and paste the code; `python3 Scripts/preset.py apply a13GkaOXWwIa --destination <folder>` writes the theme file a consumer owns

## Reference replacement

After reviewing each exported image (they are the real screens with the strip above the tab bar):

```sh
OUT=/private/tmp/claude-501/-Users-developer-Projects-swiftui-cn/7db8cc48-cfcb-4ea2-8c09-ebfba8bf4c18/scratchpad/review-2026-09-05   # or re-export: xcrun xcresulttool export attachments --path <final-suite.xcresult> --output-path "$OUT"
cd Examples/Showcase/SwiftUIRegistryShowcaseUITests/ReferenceImages
for name in auth nutrition; do
  cp "$OUT/$name-light.png" "$name-light.png"
done
```

`docs/visual-testing.md` already carries the GOLDEN-CHANGE note dated 2026-09-05 for this replacement

## Deferred: one placement rule for presentation choices (from a reading, 2026-09-06)

Mo asked me to read "Designing predictable SwiftUI design system APIs" (https://kaanbiryol.com/designing-predictable-swiftui-design-system-apis/) and record anything substantial here. The article's thesis is a three-layer call site: the initializer says what a component is (content and behavior), a component-owned trailing method says how it presents (size, variant, implemented as copy-and-return methods on the view, prefixed for discoverability), and generic SwiftUI modifiers come last; environment values stay for inherited context such as a theme; style protocols are for reacting to state SwiftUI owns or for substantially different implementations; a `ViewModifier` cannot reach a component's internal layout and is visible on every view

Measured against this registry (Registry/sources/components, 2026-09-06):

- Already the rule here: native controls take their presentation as a trailing style (`.buttonStyle(.registryOutline)`, `.progressViewStyle(.registryLinearPositive)`), text treatments as a trailing modifier with a variant argument (`registryBadge(.positive)`), the theme through the environment (`registryTheme(_:)`), and sizes through Apple's own `controlSize`. The `registry` prefix does the discoverability job the article's `ds` prefix does
- The one inconsistency: composed views carry presentation in their initializers. `InlineAlert(_:message:variant:systemImage:actions:)`, `TransactionRow(title:subtitle:amount:systemImage:tone:)`, and `MacroProgress(_:value:target:progress:systemImage:tint:)` mix how with what, so a developer who learned the styles cannot predict these three, and the Stage 5 cards inherit the mix
- The change the article argues for: move those choices to copy-and-return methods on the view, named with the prefix, applied before generic modifiers (`InlineAlert("Card delivery delayed", message:) { }.registryVariant(.positive)`, `.registryTone(.negative)`, `.registryTint(.orange)`), and write the placement rule down in `AGENTS.md` ("Rules") and `docs/architecture.md` so every future composed view follows it. Cost: three items change their public API (minor version bumps, usage snippets, demos, the blocks and preview cards that pass a variant, recaptures), plus a one-paragraph rule. Benefit: one rule for the whole registry, and the `registry` prefix then covers composed views too
- Not adopted from the article: wrapper types with a prefix (`DSButton`), because this registry keeps Apple controls visible at the call site by design; a custom style protocol per composed view, because no item needs substantially different implementations

Recommendation: do it as its own small stage after Stage 5 lands, before more composed views appear. The decision is the owner's; nothing has been changed for it

## Facts measured this session

- `inspector(isPresented:)` on a tab's navigation stack stops `@FocusState` moves in the auth form on iOS 27 even while nothing is presented; the iPad column is a plain `HStack` sibling instead (`CatalogRoot.swift`)
- argent's `describe` returns an empty tree for this app on the pinned iPhone 17 while it works on the iPad Pro 13-inch, and argent taps do not land on that iPad; XcodeBuildMCP's `snapshot_ui` and `tap` work on the iPhone. The panel's behavior is proven by the UI suite, not by argent
- The system colors the Create page draws were resolved on the pinned iOS 27 simulator with `Color.resolve(in:)` (identical to `UIColor.system*`), 2026-09-05; the table is in `Website/lib/preset.ts`

## Rules that still bind

Everything in `AGENTS.md`; no em dashes; do not push, tag, or deploy without the owner; never write into `ReferenceImages/` from an agent session
