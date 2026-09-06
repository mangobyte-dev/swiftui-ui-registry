# Component roadmap

## Goal

Deliver valuable native SwiftUI product workflows as source-owned blocks, then extract only the reusable seams those workflows prove. The shadcn catalog is research input, not a build queue: stages are vertical product slices, not component-count parity, per the committed direction review (`GENERAL_DIRECTION_REVIEW.md`, "Roadmap changes")

A component does not replace a native control. `Button`, `TextField`, `Toggle`, `Picker`, `Menu`, `ProgressView`, `ScrollView`, `NavigationStack`, and system presentations remain visible at the call site. The registry standardizes them with SwiftUI style protocols, focused `ViewModifier`s, semantic theme values, and small compositions where one primitive is insufficient

## Current state

Updated 2026-09-05. This section and the per-stage Status lines are the only home of stage status; status text in any other file is a pointer here

- Stage 1: complete, closed 2026-08-31 with findings F-001 through F-024 resolved (`STAGE_ONE_VALIDATION.md`)
- Stage 1.5: complete. The clean-room trial ran 2026-08-31 and all six recorded defects were fixed the same day (`docs/clean-room-trial.md`)
- Stage 2: complete 2026-09-01, exit evidence recorded in its section below; the seam extraction verdict was 0 of 7, nothing shared
- Stage 3: complete 2026-09-05. The activity feed is the one coherent screen; it named alert, avatar, skeleton, empty, accordion, and item, and the finance block adopted the empty-state treatment as its second consumer. Eleven presentation and navigation recipes landed alongside. Exit evidence is recorded in its section below
- Foundations grew on 2026-09-05 into the set-up-once contract: `accent` and `onAccent` tokens, `compactRadius`, six presets, and a root `registryTheme(_:)` that also applies the tint. No tag exists yet, so `0.1.0` remains the first published contract and now means this shape
- Showcase is a browsable catalog (Components, Blocks, Recipes) with a generated manifest, a demo per item, a capture launch route, and the theme tuning panel kept beside the catalog since 2026-09-05: an accent strip above the tab bar, a sheet the catalog stays interactive under on iPhone, a trailing column on iPad, with Copy Swift, Copy Code, and Import
- Stage 5 (planned 2026-09-05): the theme preview wall, shadcn's 68 create-page cards and their five missing primitives, delivered in eight serial slices; status and the card list are in its section below
- Preset codes (2026-09-05): a `RegistryTheme` as one short string that the website's Create page (`/create`), the Showcase panel, `Scripts/preset.py`, and the MCP server's `describe_preset` and `apply_preset` all read and write (`docs/registry-spec.md`, "Preset codes"); `preset.py apply` writes `RegistryTheme+App.swift` for a consumer, `capture_previews.py --preset` renders any code on the pinned simulator, and `Tests/RegistryTests/preset_vectors.json` pins the codes all three codecs reproduce
- The website is a Next.js static site built with shadcn/ui under `Website/`, fed by generated `content/registry.json`, with a page per item and a Themes page, deployed 2026-09-05 to Cloudflare Workers at https://swiftui-registry.mangobytekw.workers.dev; `docs/images/items/` and `docs/images/themes/` hold the light and dark captures
- Stage 4 (2026-09-05): the command and search screen, `command-search`, named `input-group`, `kbd`, and `command`; status and evidence in its section below
- First consumer outside `Examples/Showcase`: the seeFood app installed settings-section, select, separator, button, and input on 2026-09-01 through a local path dependency, with the receipt in its destination; the published URL remains unexercised because no tag exists
- Audit (2026-09-05): every canonical file, the foundations, and the Showcase harness were reviewed against SwiftUI best practice; 18 commits fixed the verified findings and the rest are owner decisions. Findings, evidence, and the closing count are in the Audit section below
- Current catalog counts and per-item pages live in the generated `docs/catalog/index.md` and the website, not in prose here

### Open deferrals

Standing debt already on record. A done-claim that touches one of these areas names it

- iOS 26 runtime evidence: no iOS 26 simulator runtime is installed, so the floor is verified by compilation and the iOS 27 runtime only
- The `0.1.0` tag exists locally (2026-09-05) and is not pushed, so the published URL still resolves nothing until the owner pushes it (`docs/registry-spec.md`). The site has no custom domain yet; `.github/workflows/pages.yml` remains as an alternative deploy path
- Visual threshold coarseness: the 2 percent tolerance at 96 by 192 absorbed a whole tab-bar change once (`docs/visual-testing.md`, GOLDEN-CHANGE 2026-09-01)
- seeFood's theme bridge compiles unchanged against the 2026-09-05 foundations (every new initializer argument has a default) but does not yet set `accent` or `onAccent`; adopting them is that app's decision
- Reduce Motion, VoiceOver announcement timing, and the accordion's rotation are verified structurally and on the simulator, not on a device
- Two visual references are stale after the tuning panel left its tab (2026-09-05): `auth-light` (2.67 percent; it was already stale after the audit) and `nutrition-light` (1.53 percent) because their blocks reach the accent strip that now sits above a three-tab bar; the other four references absorb the strip within tolerance (`docs/visual-testing.md`, GOLDEN-CHANGE pending). This supersedes the three stale references from the audit. Replacing them from the reviewed attachments is the owner's action (`HANDOFF.md` names the commands); the other 17 UI tests and the 7 Showcase unit tests pass
- Presentation choices sit in the initializer on three composed views (`InlineAlert` variant, `TransactionRow` tone, `MacroProgress` tint) while every style and text treatment takes them as a trailing `registry` call; moving them to prefixed copy-and-return methods and writing the placement rule down is a deferred owner decision recorded in `HANDOFF.md` (2026-09-06)
- `inspector(isPresented:)` is not used for the iPad column: measured on iOS 27, attaching it to a tab's navigation stack stopped the auth form's Return key from moving focus even while nothing was presented (`CatalogRoot.swift`), so the column is a plain sibling in an `HStack`; revisit when a later runtime behaves
- `button-group` has no visible effect: measured from its capture, `ControlGroup(configuration)` renders the stock system capsule and ignores the registry button style, the variant, and the destructive role. Whether to render the buttons in a styled HStack or demote the item to a recipe is an owner decision
- Disabled plain-Button controls dim twice (checkbox: the system dim plus `disabledOpacity`, measured from the capture) while the accordion applies no token dim; which dim wins is an owner decision

## Backlog (2026-09-05)

The honest list of what would bite the first outside adopter and what was left thin, in the order it is being worked. Each line carries its status; a done line names its evidence

1. Tag `0.1.0` so declared floors resolve. Status: local annotated tag created; pushing it is the owner's call
2. Track `AGENTS.md` and `CLAUDE.md` so contributors see the verification list. Status: done 2026-09-05, both removed from `.gitignore` and committed
3. Remove the stale pre-catalog images under `docs/images/` and mark installer `.base` snapshots as generated in `.gitattributes`. Status: done 2026-09-05
4. Search aliases from observed misses (dropdown, sheet, modal, loading, login). Status: done 2026-09-05; `aliases` is an additive item field ranked between name and tag, with 39 items aliased and tests for the hit and the non-leak. `toast` still finds nothing because no item exists for it
5. Demo walk audits accessibility per item: every button, switch, image, text field, and slider with a non-zero frame exposes a label. Status: built 2026-09-05; the first runs caught unlabeled text fields in the `input` item and, on inspection, the auth block: measured on iOS 27, neither TextField initializer exposes an accessibility label (the title is placeholder text only), so both now set explicit labels (`input` 0.4.0, `auth-form` 0.3.0) and the metadata claim was corrected and a zero-area inner node of the checkbox representation that assistive technology never exposes (audit skips zero-area nodes). Verified 2026-09-05: the walk passes all 46 demos with the audit skipping zero-area nodes and nodes enclosed by a labeled element (a native switch inside a labeled Toggle, Apple's chevron inside a disclosure header). It also caught the `item` demo hiding a toggle's label with labelsHidden
6. Visual contract tolerance: compare at 192 by 384 with a 1.5 percent tolerance. Status: done 2026-09-05; all five references pass at the tighter setting without recapture
7. Tuning panel imports a pasted `RegistryTheme` and supports a light and dark custom accent. Status: done 2026-09-05; the Import sheet parses any labeled subset of the initializer, a separate dark custom accent exports as a dynamic UIColor, and `testTuningPanelImportsAPastedThemeIntoTheKnobs` proves the round trip and the refusal of text without an initializer
8. Xcode-project clean-room trial: install a block into a scratch Xcode app, build, customize, update. Status: done 2026-09-05, recorded as Trial 2 in `docs/clean-room-trial.md`; no registry defects, one scaffold defect outside the registry
9. Website blocks story: iPad captures and a full-width block page. Status: done 2026-09-05; `capture_previews.py --blocks` captures every block on the iOS 27 iPad Pro 13-inch and each block page shows the wide layout under On iPad
10. MCP adapter over the registry JSON (search, plan, install) for agents inside consuming apps. Status: done 2026-09-05; `Scripts/mcp_server.py` is a dependency-free stdio server tested end to end over JSON-RPC
11. A Swift CLI or SwiftPM plugin so adopters do not need Python. Status: deferred 2026-09-05 with reasons: macOS ships Python 3 with the Xcode command line tools, and a second installer would fork the single validator and the receipt logic the doctrine keeps in one place; revisit if an adopter reports Python as a blocker
12. Usage-snippet compile proof for installable items independent of the Showcase demos. Status: closed 2026-09-05: snippets reference caller state (`$email`, `rows`, `onSelect`) that a generic wrapper cannot supply without per-item fixtures, which would duplicate the demos; the demos remain the compile proof and the walk proves each exists
13. iOS 26 simulator runtime for floor evidence. Status: open, needs a multi-gigabyte download on the owner's machine
14. Custom domain for the Worker plus `X-Robots-Tag: noindex` on the workers.dev host. Status: open, needs the owner's domain
15. Stage 4: a command and search screen naming `command`, `kbd`, and `input-group`. Status: done 2026-09-05; evidence in the Stage 4 section
16. Create page and preset codes, the registry's counterpart of shadcn's `/create` and `--preset`. Status: done 2026-09-05. One codec in three languages (`Scripts/preset.py` the reference, `Website/lib/preset.ts`, the Showcase's `ThemePreset.swift`) with 26 pinned vectors checked by `test_preset.py` (Python and, through Node, TypeScript) and the Showcase package's `ThemePresetTests` (7 tests, run by the app scheme); `preset.py decode | url | apply | resolve | random`, with `apply` refusing to replace an edited theme file; MCP `describe_preset` and `apply_preset`; the website `/create` page with the token board, the six preset captures, the Swift, the apply commands, Open, Random, Reset, and a shareable `?preset=` URL; the Showcase's Copy Code, Import of a code, `-preset <code>` launch, and `capture_previews.py --preset`. A mutation pass over the Python codec, CLI, and MCP tools killed all 18 mutants after three survivors were fixed (a misplaced test method, a dead parse branch, an untested MCP `force` check)
17. The tuning panel beside the catalog, shadcn's customizer layout on device. Status: done 2026-09-05. The Tune tab is gone; `TuningAccessory` (named accents plus the Tune button, in `tabViewBottomAccessory`) is on every catalog screen, the panel is a `.medium`/`.large` sheet with `presentationBackgroundInteraction` on iPhone and a 380-point trailing column on iPad, sections are separate views, and `CopyButton` replaces three copies of the copy-and-reset code. Evidence: `testTuningStaysUpWhileBrowsingAndSpeaksPresetCodes` pushes a component while the panel stays up and imports a code; the same export test passes on the iPad Pro 13-inch destination. The final full run: 19 UI tests with 17 passing and the `auth` and `nutrition` visual references awaiting the owner's copy (Open deferrals), plus the 7 unit tests; the commands are in `HANDOFF.md`

## Audit (2026-09-05): SwiftUI best practice

How it ran: `/uncle-bob-swarm` was not available, so the audit was planned as a fan-out with a refuting verify phase; that fan-out exhausted the session limit before any verify agent completed (36 finder reports over 18 items came back, 133 agents failed) and the remaining 14 items, the foundations, and the Showcase harness were audited serially by the lead. Every finding below was verified by the lead against the quoted rule and, where it says measured, by the compiler, the SDK interface, a capture image, or the pinned simulator. Rule sources are the skill references named in `HANDOFF.md`: `swiftui-specialist/references` (Apple guidance), `swiftui-pro/references`, `swift-concurrency-pro/references`, and `pfw-modern-swiftui`

Measured facts that settled whole axes: a type-check of every registry source, the foundations, and the Showcase with `-Xfrontend -warn-soft-deprecated` reports one soft-deprecated reference, `URL(fileURLWithPath:)` in the capture screen, and no SwiftUI one; `overlay(theme.border)` resolves to the ShapeStyle overload (the View overload is `@_disfavoredOverload`); `tint(_ tint: Color?)` is `environment(\.tintColor, tint)` with a package-private key, so `tint(nil)` resets rather than inherits (also confirmed on the simulator under a green ancestor tint); `TextFieldStyle` has only the underscored `_body(configuration:)` requirement

### Findings

| Item | File and line | Axis | Rule | Consequence | Status |
|---|---|---|---|---|---|
| foundations | `Sources/SwiftUIRegistryFoundations/RegistryTheme.swift:175` | performance | modifiers.md: "State reset: Any `@State` in the view or its descendants resets when the condition changes" | Measured: choosing the System preset (accent nil) on the Tune tab recreated the TabView, bounced the app to Components, and popped the Blocks stack | Deferred in foundations: `tint(nil)` resets, so the branch is the only way to inherit; documented in a76df37. The Showcase keeps its accent non-nil in 938da68 |
| foundations | `RegistryTheme.swift:22` | foundations | architecture.md Foundations contract; the button draws `Color.white` on `negative` | A light `negative` gives a white-on-light destructive label with no warning | Doc comment on the token, a76df37 |
| skeleton | `Registry/sources/components/RegistrySkeletonModifier.swift:30` | performance | modifiers.md: "View identity loss: The `if`/`else` inside the modifier creates two branches with different view types" | Flipping `isActive` replaced the wrapped content's identity and state, contradicting the API doc | Fixed 9088d47 |
| kbd | `RegistryKeycapModifier.swift:36` | performance | same rule | The keycap was rebuilt whenever a label appeared or disappeared | Fixed 5acf6db |
| transaction-row | `TransactionRow.swift:52` | performance | modifiers.md: "PREFER: Use a ternary expression in the modifier argument" | A row was rebuilt when its tone changed; two conventions across items | Fixed 8f142c3 |
| activity-feed | `Registry/sources/blocks/ActivityFeed.swift:154` | performance | performance.md: "prefer ternary expressions over if/else view branching to avoid `_ConditionalContent`" | The notice was replaced when a dismiss handler came or went | Fixed 3fb6fcb |
| activity-feed | `ActivityFeed.swift:65` | performance | structure.md: "SwiftUI re-runs the body of the smallest enclosing view that depends on what changed" | Every Earlier toggle re-ran the whole feed through block-owned state the native group holds itself | Fixed 3fb6fcb |
| metric-card, transaction-row, command, checkbox, avatar, activity-feed | `MetricCard.swift:60`, `TransactionRow.swift:104`, `CommandPalette.swift:143`, `RegistryCheckboxToggleStyle.swift:39`, `Avatar.swift:55`, `ActivityFeed.swift:197` | correctness | design.md: "Prefer to avoid fixed frames for views unless content can fit neatly inside; this can cause problems across different device sizes, different Dynamic Type settings, and more" | Text-style symbols and monograms outgrew or truncated inside fixed 40, 28, 22, and 8 point frames at accessibility sizes | Fixed with `@ScaledMetric`; default sizes unchanged (recaptures byte-identical): 8f142c3, 508d583, 8e1a0c7, 9babb5f, 3fb6fcb |
| input | `RegistryInputStyle.swift:22` | correctness | design.md: "Apple's minimum acceptable tap area for interactions on iOS is 44x44" | Measured 42.7 point empty fields, 40 to 43 at small text sizes, below the token the siblings enforce | Fixed ad1a261 |
| input-group | `InputGroup.swift:47` | correctness | AGENTS.md: "Support Dynamic Type ... rather than hardcoding one context" | No vertical inset: large text touched the border and the height rule differed from input | Fixed ad1a261 |
| accordion | `RegistryAccordionStyle.swift:39` | correctness | Apple, `AccessibilityTraits.isSelected`: "The accessibility element is currently selected." | VoiceOver spoke selected and Expanded for one state | Fixed d7b0851 |
| accordion | `RegistryAccordionStyle.swift:44` | architecture | AGENTS.md: "Keep raw SwiftUI controls and containers visible at the call site. Standardize interactive appearance with SwiftUI style protocols" | The style restyled arbitrary caller content; the activity feed's Earlier rows rendered in secondary gray (measured) | Fixed d7b0851 |
| finance, nutrition, activity-feed, command-search, auth-form | `FinanceOverview.swift:100,111`, `NutritionOverview.swift:69,80`, `ActivityFeed.swift:107`, `CommandSearch.swift:44`, `AuthForm.swift:153` | correctness | philosophy.md: "VoiceOver semantics ... are release requirements"; settings-section already carries the trait | The Headings rotor skipped screen and section titles | Fixed 8f142c3, 3fb6fcb, 508d583, 59347cd |
| finance, activity-feed, command | `FinanceOverview.swift:136`, `ActivityFeed.swift:204`, `CommandPalette.swift:153` | correctness | accessibility.md: "If buttons have complex or frequently changing labels, recommend using `accessibilityInputLabels()`" | Voice Control had only the compound row label to say | Fixed 8f142c3, 3fb6fcb, 508d583 |
| auth-form | `AuthForm.swift:98,117` | modern-api | `accessibilityHint(_:isEnabled:)`: "If true the accessibility hint is applied; otherwise the accessibility hint is unchanged" | Healthy fields carried an empty hint attribute | Fixed 59347cd |
| auth-form | `AuthForm.swift:156` | performance | performance.md: "assume each view's `body` property is called frequently" | Three `String(localized:)` lookups on every keystroke; `LocalizedStringResource` is Equatable | Fixed 59347cd |
| alert, badge, button, checkbox | `InlineAlert.swift:95,103`, `RegistryBadge.swift:73`, `RegistryButtonStyle.swift:170`, `RegistryCheckboxToggleStyle.swift:40` | performance | modifiers.md: "`AnyShapeStyle` is the right answer whenever the branches must produce different `ShapeStyle` types" | Erasure where every branch was a `Color` | Fixed 91db023, d32eeee, ea9445b, 8e1a0c7 |
| button | `RegistryButtonStyle.swift:67` | correctness | Apple, Button: "Custom styles can also read the button's role and use it to adjust the button's appearance"; button.json promised "preserving roles" | Delete in an outline group looked like Duplicate | Fixed ea9445b (the group still hides it, see Deferred) |
| macro-progress | `MacroProgress.swift:60` | localization | localization.md: "Never glue separately localized fragments to form a sentence" | The value, of, target phrase could not be reordered by a translator | Fixed a74a1fd, recaptured |
| activity-feed | `ActivityFeed.swift:214` | localization | localization.md: "Use `Text(verbatim:)` to opt out of localization for a string literal" | Four never-shown placeholder keys extracted into consumer catalogs | Fixed 3fb6fcb |
| command, command-search | `CommandPalette.swift:174`, `CommandSearch.swift:128`, the demos | localization | swift.md: "Filtering text based on user-input must be done using `localizedStandardContains()`" | The example filter missed diacritic and hamza variants | Fixed 508d583, 938da68 |
| command, command-search | `CommandPalette.swift:172`, `CommandSearch.swift:125`, the demos | localization | localization.md: "Xcode cannot extract a literal from a runtime value" | Section titles never reached the catalog | Fixed 508d583, 938da68 |
| activity-feed, accordion, command, command-search | `ActivityFeed.swift:83,85,205`, `RegistryAccordionStyle.swift:40`, `CommandPalette.swift:63`, `CommandSearch.swift:25` | localization | localization.md: "Add a `comment` ... especially for ambiguous strings" | Search, Recent, Earlier, Expanded, Collapsed, and Unread arrived without context | Fixed 3fb6fcb, d7b0851, 508d583 |
| kbd | `RegistryKeycapModifier.swift:57`, kbd.json usage | localization | same verbatim rule | Key glyphs extracted as localizable keys | Fixed 5acf6db |
| kbd | `RegistryKeycapModifier.swift:26` | architecture | AGENTS.md: "Use semantic foundation tokens instead of repeated hardcoded colors or metrics" | The Tune density knob did not move keycap padding with badges | Fixed 5acf6db |
| command-search | `CommandSearch.swift:77` | correctness | foreach.md: identity must be "unique (no two distinct elements share an id in the same `ForEach`)" | Two legend lines with the same keys collided | Fixed 508d583, explicit id defaulting to keys |
| input-group | `InputGroup.swift:94,106,117`, usage | localization, correctness | data.md: "bind the `TextField` to a numeric value ... then use its `format` initializer"; localization.md comments | The preview taught a string-bound decimal field, an ambiguous Clear, and a prefix the field's label did not carry | Fixed ad1a261 |
| item | `ItemRow.swift:88,117`, item.json | architecture, claim | registry-spec.md: usage is "a minimal compiling SwiftUI snippet"; philosophy.md native first | The usage snippet did not compile after install (Avatar absent from the closure); the switch row spoke its label twice | Fixed ef480ae |
| alert | `InlineAlert.swift:149`, the demo | adaptivity | localization.md: "Use `ViewThatFits` when a layout might not fit" | Preview buttons overflowed at accessibility sizes | Fixed 91db023, 938da68 |
| checkbox, button | previews | correctness | AGENTS.md: "Preview every meaningful variant" | The mixed state and the mini and extra-large sizes had no evidence | Fixed 8e1a0c7, ea9445b |
| activity-feed | `ActivityFeed.swift:276`, the demo | correctness | Avatar doc: "Required because a face or monogram cannot be read" | A WB monogram on the Harbor Bank row | Fixed 3fb6fcb, 938da68, recaptured |
| metadata claims | button, badge, alert, input, input-group, checkbox, activity-feed, auth-form, accordion, settings-section, item, kbd, button-group tag | accessibility-claim | AGENTS.md "Document map" and "Agent legible" | Consumers read overstated or stale contracts, for example a Stage 2 question the roadmap closed, "fill and border treatments" positive and destructive do not carry, and "does not rely on color alone for destructive actions" | Fixed in the item commits above and 8f142c3 |
| captures | `docs/images/items/input-light.png`, `input-group-light.png` | correctness | AGENTS.md: "Item screenshots come from `python3 Scripts/capture_previews.py`" | The catalog and website showed the simulator home screen as two light previews; the demo reports its frame before a cold launch reaches the screen | Fixed 390db1c: the script accepts a screenshot only when its top-left pixel is the app background, then recaptured |
| harness | `TuningPanel.swift:123,134,145` | architecture | pfw-modern-swiftui: "NEVER use `Binding.init(get:set:)` to derive bindings" | Model logic hidden in closure bindings rebuilt on every body | Fixed 938da68 |
| harness | `BlockDemos.swift:131`, `TuningPanel.swift:62`, `CatalogRoot.swift:189` | concurrency | cancellation.md: ".task() modifier cancels its task automatically when the view disappears" | Timers outlived their views; a second Copy tap cut the label short | Fixed 938da68 |

### Deferred, with the reason

- `button-group`: measured from `docs/images/items/button-group-light.png`, both groups render as the stock system capsule; inside `ControlGroup(configuration)` the registry style, the variant, and the destructive role are invisible, so the item currently fails the value gate. Options: render `configuration.content` in a styled `HStack` (which drops the "retains the system group container" claim) or demote the item to a recipe. Owner decision
- Checkbox disabled state dims twice (the plain button style's own dim plus `disabledOpacity`, measured from the capture) and the accordion applies no token dim: pick the system dim or the token for plain-Button-based controls. Owner decision, `RegistryCheckboxToggleStyle.swift:24`, `RegistryAccordionStyle.swift:15`
- Bare `Divider()` in `FinanceOverview.swift:139` and `NutritionOverview.swift:95` ignores `theme.border`; the fix adds `separator` to both closures and changes the pinned resolve order. Owner decision, already flagged in the Stage 2 seam decision
- `NutritionOverview.swift:103` uses `.borderedProminent`, ignoring `onAccent` and `controlRadius` (the Amber preset shows white on yellow); the fix adds `button` to the closure. Owner decision
- The tint and tone washes use five literals (0.10, 0.12, 0.14, 0.16, 0.35 across alert, metric-card, transaction-row, badge, checkbox) for one meaning; a token or one agreed literal. Owner decision
- Preview guards: six files wrap previews in `#if DEBUG`, 26 do not. Owner decision
- Preview sample copy is `LocalizedStringKey` literals that a consumer's string catalog extracts (measured with `swiftc -emit-localized-strings`); verbatim previews or a documented policy. Owner decision
- Item literals default to `Bundle.main`; an install into a package that owns the catalog resolves them in English. Policy decision: document, or route literals through `#bundle`
- Focus bindings for `CommandPalette` and `AuthForm` (a caller cannot focus the search or identity field), the `AuthForm` secondary action pair, the `.asciiCapable` username keyboard, an unchanged error message not re-announced (now stated in the claim), the keycap's optional spoken label, and the public shell plus private content split in finance, metric-card, and transaction-row are API decisions
- `RegistryInputStyle` implements the underscored `_body(configuration:)`, the only requirement `TextFieldStyle` has (SDK interface): an accepted SPI risk, now on record
- The invalid state hides the focus ring in input, input-group, and textarea (invalid wins the color at the same width); the claims now say so; changing the treatment is a design decision
- Alert actions at `.controlSize(.small)`, `.caption2` for mini buttons and avatars, and `Equatable` on `RegistryTheme` were considered and left alone (environment.md warns against defensive additions; no measured cost)
- Visual references: `auth-light.png` fails at 1.95 percent because the approved image predates the wrapping code block (both landed in e2a75ef) and the fields are now 44 points; `activity-light.png` (HB) and `nutrition-light.png` (phrase) pass but are stale. The reviewed attachments from the audit run are in `~/Library/Developer/XcodeBuildMCP/workspaces/swiftui-cn-13dead7d9e93/result-bundles/test_sim_2026-09-05T15-53-39-426Z_pid51858_2d4a0bdc.xcresult` (`xcrun xcresulttool export attachments --path <bundle> --output-path <dir>`, attachments named `auth-light`, `activity-light`, `nutrition-light`); copying the three over `Examples/Showcase/SwiftUIRegistryShowcaseUITests/ReferenceImages/` with a GOLDEN-CHANGE note in `docs/visual-testing.md` is the owner's action, because the harness refused the file replacement during the audit

### Checked and not a finding

Soft-deprecated API (the compiler check found none in SwiftUI code); `overlay(theme.border)` (ShapeStyle overload); `ViewThatFits` with two hand-written alternatives (the idiom); `if x.id != last { Divider() }` inside a `VStack` (not the lazy fast path); the `@Entry var registryTheme` default (stable value); an unconditional `.tint(theme.accent)` as the fix for the theme flip (measured on the simulator: `tint(nil)` reset a green ancestor tint to system blue, so the branch stays)

### Closing count

- Read: all 32 canonical files, `RegistryTheme.swift`, the Showcase demos and harness, `test_installer.py`, and the UI suite. Eighteen items had two independent finder passes before the fan-out failed (accordion, activity-feed, alert, auth-form, avatar, badge, button, button-group, card, checkbox, command, command-search, empty, finance-overview, input, input-group, item, kbd); the other fourteen, the foundations, and the harness were audited by the lead alone
- Fixed: 18 commits, 390db1c through 938da68. Deferred: the list above. Not fixed because the harness refused it: the three reference images
- Run on the final tree: `validate.py`, 92 Python tests, the foundations package tests, the Showcase build, the 18-test UI suite (17 passed; `auth-light` reference, above), captures for the changed items and the iPad blocks, the website typecheck and build. Each commit passed the validator, the reinstall, the three generators, and the Python tests with only its own files present; the build and the UI suite ran once over the whole batch, not per commit
- Not run: the Xcode-project clean-room trial, any device, and an iOS 26 runtime (none installed)

## Implementation rules

1. Keep the Apple primitive visible at the call site. Prefer `.buttonStyle(...)`, `.toggleStyle(...)`, `.textFieldStyle(...)`, `.labelStyle(...)`, `.progressViewStyle(...)`, and focused view modifiers
2. Use `@ViewBuilder` when a composition provides consistent structure or chrome around arbitrary caller content. Use a fixed composition only when several primitives must cooperate, such as an input group, OTP entry, command palette, attachment, or message
3. Keep caller-controlled state external through bindings. A component may own transient `@State` only when the interaction is self-contained and no caller, block, restoration flow, or product rule must coordinate it
4. Components accept prepared values and actions and do not import application architecture, networking, or persistence
5. Keep system-owned presentation and interaction behavior. Style sheet content, menu labels, rows, and triggers without replacing `.sheet`, `.alert`, `.popover`, `Menu`, navigation, scrolling, focus, or selection
6. Prefer a focused modifier for independent optional behavior instead of expanding an initializer with unrelated parameters
7. Give optional parameters sensible defaults so the common case stays concise
8. Use semantic foundation tokens instead of repeated hardcoded colors and metrics. Add a token after at least two completed items need the same meaning. Keep a style or modifier source-owned until two items use the exact same treatment
9. Respect Dynamic Type, color scheme, layout direction, enabled state, and parent layout proposals. Require accessibility input when it cannot be derived from visible content
10. Preview every meaningful variant, including dark appearance and an accessibility Dynamic Type size
11. Do not add a helper abstraction inside an item without two concrete consumers or named block usages
12. Every completed item needs registry metadata, a call-site `usage` snippet, realistic previews, accessibility notes, RTL and large-text coverage, installation into Showcase, and a compile path at the declared platform floor
13. Blocks do not wait for a complete component catalog. A block lands when its actual dependency closure is complete, and it is the evidence that decides which components deserve to exist

## Stage 1: Core styled primitives

**Status: Complete**

At Stage 1 close the catalog held 26 items: 17 installable components, 2 blocks, and 7 recipes. All 21 original Stage 1 rows are indexed: 14 are installable components, source-owned, installed into Showcase, and compiled at the iOS 26 platform floor; the remaining 7 rows (`aspect-ratio`, `direction`, `native-select`, `radio-group`, `tabs`, `switch`, `slider`) are recipes, native guidance carried in item `docs` with no installable files, per the item value gate in `docs/registry-spec.md`. The 3 block-driven components (`metric-card`, `transaction-row`, `macro-progress`) and the 2 proof blocks (`finance-overview`, `nutrition-overview`) complete the count. Launch Showcase with `-stage-one` to inspect the catalog

Stage 1 exit criteria were met: every foundation token is used by at least two completed registry items with the same semantic meaning; enabled, pressed, focused, selected, disabled, and invalid states are demonstrated where applicable; the showcase proves light, dark, RTL, and accessibility text sizes. Runtime and compile evidence is recorded in `STAGE_ONE_VALIDATION.md`

## Stage 1.5: Adoption contract

**Status: Complete**

This stage makes one external install/customize/update workflow excellent before adding breadth. What is in place:

- Item taxonomy and value gate: the `recipe` kind separates native guidance from installable source, and an installable item must add a meaningful reusable treatment or composition (`docs/registry-spec.md`, "Item value gate")
- Unified validation: `Scripts/registry_validation.py` is the single structural validator used by install, search, `Scripts/validate.py`, catalog generation, and CI tests
- Inspectable install: `Scripts/install.py --plan` prints the ordered closure, per-target statuses, package requirements, collisions, and manual integration steps without writing; `--diff` audits owned source against canonical registry source
- Actionable package metadata: every version requirement carries a `sourceURL` and a machine-resolvable `swiftPM` rule, with the compatibility policy in `docs/registry-spec.md`
- Generated per-item documentation: `docs/catalog/` is generated from metadata by `Scripts/generate_catalog.py`, each page leading with preview, install command, and a `usage` snippet, with recipes leading with the snippet because nothing installs; a freshness test keeps it byte-identical to the metadata
- Clean-room trial: **complete**. The independent-adopter protocol ran on 2026-08-31 against a scratch SwiftPM package outside this repository, working from README and the generated catalog alone. Discover, inspect, install, compile, customize, and update-safety all passed; six defects were recorded and all six were fixed the same day (`docs/clean-room-trial.md`). Its remaining deferrals (published URL and tag, `--update` merge, Xcode-project consumer) are tracked under Current state

## Stage 2: Two block-led workflows

**Status: Complete**

Build two complete product workflows as dependency-closed blocks, then extract shared treatments only from proven repetition

1. **Authentication form**: sign-in and sign-up surfaces exercising validation, focus order, secure input, autofill, and error feedback
2. **Settings section**: grouped preferences exercising switches, selection, separators, and destructive actions

Extract `field`, `input-group`, or form treatments only when the two slices prove the same seam. Do not pre-build a forms catalog

### Stage 2 seam extraction decision (2026-09-01)

`Registry/sources/blocks/AuthForm.swift` and `Registry/sources/blocks/SettingsSection.swift` were compared side by side for every shared seam candidate. No candidate met the same-treatment bar, so nothing was extracted and both blocks keep their treatments source-owned (Evidence before extraction, docs/philosophy.md):

- Field-with-message column: KEEP LOCAL. AuthForm renders footnote messages in `theme.negative` with an `accessibilityHint` and an announcement on change (validation errors); SettingsSection renders footnotes in `.secondary` with no hint and no announcement (descriptions, disabled explanations, footer). Same rough shape, different semantics and styling
- Footnote message treatment: KEEP LOCAL. The only identical fragment is `.font(.footnote)`; foreground styles differ (`theme.negative` versus `.secondary`) because error and description are distinct roles
- Announce-on-change helper: KEEP LOCAL. One consumer (AuthForm). SettingsSection deliberately relies on native disabled semantics plus visible text and posts no announcements
- Busy-button treatment: KEEP LOCAL. One consumer (the AuthForm submit button)
- Section chrome: KEEP LOCAL. AuthForm titles through `GroupBox` with `.registryCard`; SettingsSection uses a header-trait headline above `registrySurface()` with an optional footnote footer. Different structures, and the card treatment is already shared via `RegistryCardStyle`
- Disabled treatment: KEEP LOCAL. AuthForm disables the whole form during submit; SettingsSection disables per row while keeping the explanation outside the disabled subtree
- Separator-interleaved rows: KEEP LOCAL. Only SettingsSection uses separators between these two blocks. The bare `Divider()` in FinanceOverview and NutritionOverview versus `registrySeparator()` here stays a flagged cleanup candidate, not an extraction with two proving usages in this pair

### Stage 2 exit criteria

- Both blocks install, compile, and render from their resolved closures at the iOS 26 floor
- Focus order, keyboard behavior, validation announcements, autofill, and disabled states are verified at the UI
- Every composition accepts bindings and actions without owning validation, upload, or persistence logic
- Any extracted shared treatment names its two proving usages

### Stage 2 exit-criteria evidence (2026-09-01)

Verified on the pinned light-mode iPhone 17 iOS 27.0 simulator by `SwiftUIRegistryShowcaseUITests`:

- Focus order and keyboard behavior: `testAuthReturnKeyMovesFocusFromIdentityToPasswordAndSubmits` proves the Next return key moves typing from the identity field to the password field and the Go return key runs the caller's submit
- Disabled states: `testAuthSubmitDisablesFieldsAndSubmitControlWhileSubmitting` proves both fields and the submit control report isEnabled false while the harness isSubmitting is true and re-enable after; `testSettingsRowsWriteThroughCallerBindingsAndReportDisabledState` proves the organization-managed row reports isEnabled false with its explanation legible
- Validation feedback: `testAuthValidationSurfacesFieldAndFormErrorCopy` proves field and form error copy appears as accessibility elements and clears on correction. XCUITest cannot observe VoiceOver announcement delivery or read accessibilityHint, so the announcement, hint, and autofill content types (`.textContentType(.username)` / `.password`) are pinned structurally by `test_auth_block_keeps_credential_autofill_and_error_announcements` in `Tests/RegistryTests/test_installer.py`; autofill UI itself is verifiable only manually with a saved credential
- Bindings and actions without owned logic: `testSettingsRowsWriteThroughCallerBindingsAndReportDisabledState` proves toggle writes flow through caller state and the destructive action runs caller code; validation and the fake submission live in the Showcase harness, not the blocks
- Adaptive rendering: `testStageTwoScreensAdaptToAccessibilitySizeAndRightToLeft` proves both screens scale with accessibility type and mirror leading-aligned content under right to left
- Visual contract: `auth-light.png` and `settings-light.png` were added per `docs/visual-testing.md`, with the GOLDEN-CHANGE note recorded there

## Stage 3: Content and feedback driven by one real screen

**Status: Complete**

The screen is a banking activity feed (`activity-feed`): a notice above recent activity, avatar-led rows with unread state, a loading placeholder, an empty state, and an Earlier section that expands. It named exactly these treatments, each shipped as a source-owned component with the feed as its first consumer:

- `alert` (`InlineAlert`): informational, positive, and destructive variants pairing a symbol with a color, with optional caller-owned actions
- `avatar` (`Avatar`): image, initials, or symbol fallback sized by control size, with a required accessibility label
- `skeleton` (`registrySkeleton`): native redaction, no interaction, one loading element, pulse off under Reduce Motion
- `empty` (`registryEmptyState`): a native `ContentUnavailableView` on the registry surface; the finance block is its second consumer
- `accordion` (`RegistryAccordionStyle`): a `DisclosureGroupStyle` with a full-width header and chevron
- `item` (`ItemRow`): media, title, description, accessory, with selection left to the call site

Presentation and navigation candidates shipped as recipes, not wrappers: `alert-dialog`, `dialog`, `drawer`, `popover`, `context-menu`, `dropdown-menu`, `tooltip`, `calendar`, `collapsible`, `scroll-area`, and `sidebar`. Each snippet compiles in the Showcase's recipe demos

### Stage 3 exit criteria

- Feedback is distinguishable without color alone
- Decorative imagery is hidden from accessibility and meaningful media has caller-provided labels
- Placeholder states do not trigger product actions or effects

### Stage 3 exit-criteria evidence (2026-09-05)

Verified on the pinned light-mode iPhone 17 iOS 27.0 simulator by `testActivityFeedStatesAreDistinguishableAndPlaceholdersNeverAct` in `SwiftUIRegistryShowcaseUITests`:

- Not color alone: the unread row reports the accessibility value Unread alongside its dot and heavier title; the notice pairs a symbol with its variant color; the accordion header reports Collapsed and Expanded
- Decorative imagery: the alert symbol, the unread dot, and the accordion chevron are hidden; every avatar carries the caller's sender name, and the row buttons expose title, detail, and timestamp in one label
- Placeholders never act: in the loading state the rows are gone from the button tree, one element labeled Loading activity stands in, and tapping it produces no selection; the empty state shows the caller's copy; the loaded state selects, expands Earlier, and dismisses the notice through caller code
- Visual contract: `activity-light.png` was added per `docs/visual-testing.md`

## Stage 4: Command and search driven by one real screen

**Status: Complete**

The screen is a global search (`command-search`): a search field with a leading symbol and a clear button, caller-filtered sections of commands with optional shortcut hints, the native empty state for no results, and a shortcut legend for keyboard users. It named exactly these treatments:

- `input-group` (`InputGroup`): registry input chrome around a native field with leading and trailing accessories
- `kbd` (`registryKeycap`): a keycap for shortcut hints, hidden from accessibility unless a spoken label is given
- `command` (`CommandPalette`): the input group over sectioned item rows, keycaps, and the empty state, with the query and the filtering left to the caller

### Stage 4 exit criteria

- Filtering, ranking, and what a command does stay with the caller; the palette never triggers an action on its own
- No results renders the native empty state with caller copy
- Shortcut hints are never bare glyphs to assistive technology: either spoken or hidden
- The search field is a labeled native text field with the search return key

### Stage 4 exit-criteria evidence (2026-09-05)

Verified on the pinned light-mode iPhone 17 iOS 27.0 simulator by `testCommandSearchFiltersEmptiesAndRunsCallerCommands`: typing narrows the list through the caller's filter and non-matching commands leave it; a query with no matches shows the native No results state with the caller's copy; Clear search restores the sections; selecting a command runs caller code (the harness caption reports it); the shortcut legend exposes the spoken shortcut. The 50-item demo walk with the accessibility audit passes, so every new control and image carries a label. Light and dark captures exist for the three components and the block, plus the block on iPad

## Stage 5: the theme preview wall, shadcn's `/create` preview recreated

Status: in progress. Slice 1 (the `field`, `chart`, `table`, `combobox`, `breadcrumb` primitives) is on main; slice 2 (the `preview` block with cards 1 to 11: activate-agent-dialog, analytics-card, anomaly-alert, assign-issue, bar-chart-card, bar-visualizer, book-appointment, codespaces-card, contributions-activity, contributors, environment-variables), slice 3 (cards 12 to 22: feedback-form, file-upload, github-profile, icon-preview-grid, invite-team, invoice, live-waveform, no-team-members, not-found, observability-card, pie-chart-card, with third-party brand copy neutralized across the wall), and slice 4 (cards 23 to 33: report-bug, shipping-address, shortcuts, skeleton-loading, sleep-report, style-overview, typography-specimen, ui-elements, usage-card, visitors, weekly-fitness-summary, which finishes the 33-card block and bumps it to 0.3.0) are done 2026-09-06; slice 5 (the `preview-02` block created at 0.1.0 with cards 1 to 12: account-access, album-card, card-overview, catalog-toolbar, claimable-balance, contribution-history, cover-art, dividend-income, empty-connect-bank, empty-distribute-track, empty-explore-catalog, faq) is done 2026-09-06. Owner's instruction: recreate every element shadcn's `/create` page shows while a theme is being composed, so the Showcase's tuning panel and the website's Create page preview a wall of realistic product UI instead of one strip

What shadcn shows: its create page previews two registry blocks, `preview` (33 cards) and `preview-02` (35 cards), each a seven-column masonry of cards built from the ui primitives (`apps/v4/registry/bases/base/blocks/preview*/cards/*.tsx` in shadcn-ui at 7c9eaba). Measured against this registry on 2026-09-05, the primitives those 68 cards use are all present as components or recipes except five: `field` (20 cards), `chart` (11 cards, Swift Charts), `combobox` (2), `table` (2), and `breadcrumb` (1)

Delivery, one serial slice per Opus 4.8 worker run, each slice a dependency-closed unit (source, metadata with usage and accessibility, preview, demo, captures, generators, tests, compile, one commit per item or block):

1. Primitives: `field`, `chart`, `table`, `combobox`, `breadcrumb`. Native controls stay visible; each earns its place under the value gate or ships as a recipe
2. Block `preview`, cards 1 to 11: activate-agent-dialog, analytics-card, anomaly-alert, assign-issue, bar-chart-card, bar-visualizer, book-appointment, codespaces-card, contributions-activity, contributors, environment-variables
3. Block `preview`, cards 12 to 22: feedback-form, file-upload, github-profile, icon-preview-grid, invite-team, invoice, live-waveform, no-team-members, not-found, observability-card, pie-chart-card
4. Block `preview`, cards 23 to 33 plus the block itself: report-bug, shipping-address, shortcuts, skeleton-loading, sleep-report, style-overview, typography-specimen, ui-elements, usage-card, visitors, weekly-fitness-summary; the masonry layout, metadata, demo, iPhone and iPad captures (done, 2026-09-06: all 33 cards render in the Showcase; the compact wall became a non-lazy `VStack` so `testEveryRegistryItemHasADemoInTheCaptureRoute` covers every card on the pinned iPhone and passes with zero unlabeled controls, after the one it flagged, the native switch in ui-elements, was given `labelsHidden` and an explicit accessibility label; iPhone `preview-{light,dark}.png` and iPad `preview-ipad-{light,dark}.png` captures regenerated; block bumped to 0.3.0)
5. Block `preview-02`, cards 1 to 12: account-access, album-card, card-overview, catalog-toolbar, claimable-balance, contribution-history, cover-art, dividend-income, empty-connect-bank, empty-distribute-track, empty-explore-catalog, faq (done, 2026-09-06: the `preview-02` block was created at 0.1.0 with these first 12 cards, translated from shadcn's second create-page preview; album-card and cover-art draw themed placeholders instead of images, card-overview, contribution-history, and dividend-income use registryChart() on Swift Charts, catalog-toolbar uses input-group and toggle-group, faq pairs a segmented Picker with the accordion style, and all third-party brands are neutralized. The compact wall is a non-lazy VStack, so `testEveryRegistryItemHasADemoInTheCaptureRoute` audits every card on the pinned iPhone and passes with zero unlabeled controls, no fixes required. iPhone `preview-02-{light,dark}.png` captured; slices 6 and 7 append the remaining 23 cards)
6. Block `preview-02`, cards 13 to 24: front-door, index-investing, kitchen-island, loading-card, new-milestone, notification-settings, payments, payout-threshold, power-usage, preferences, qr-connect, receiving-method
7. Block `preview-02`, cards 25 to 35 plus the block itself: recent-transactions, release-catalog, roller-shades, savings-progress, savings-targets, sidebar-nav, social-links, stock-performance, syncing-state, transfer-funds, upcoming-payments
8. Wire-up: the `theme-preview` capture route and the website's Create page render the `preview` wall, the preset captures regenerate, and the docs record the stage

Rules that bind every slice: `AGENTS.md` in full; a card composes registry items and native controls with sample data, never a wrapper that renames an Apple control; charts use Swift Charts; the animated visualizers use `TimelineView` and `Canvas`; nothing is pushed; visual references are never regenerated to pass a test

### Stage 5 exit criteria

- Every one of the 68 cards renders in the Showcase under all six presets and both appearances, and the two blocks install through `Scripts/install.py` with their closures
- The five primitives have metadata, previews, demos, captures, and accessibility notes like every other item
- The Create page shows the wall for the six presets, and the tuning panel's preview on device is the same wall

## Later

Complex data, presentation guidance, and messaging proceed only on evidence from named adopters. Native sheets, alerts, menus, navigation, scroll views, and split views are recipes by default, not installable wrappers. Finance and nutrition remain proof fixtures; illustrative domains do not count as adoption evidence

Deferred until real adoption proves the need: hosted registry distribution, namespaces, authentication, federation, MCP, marketplace and multi-author workflows, automatic `.xcodeproj` mutation, macOS/watchOS/tvOS/visionOS claims, and a large typography/color/elevation token framework

## Delivery unit

Implement one dependency-closed vertical slice at a time. Each merged slice includes its style or modifier source, metadata with a `usage` snippet, preview, accessibility notes, showcase installation, registry tests, catalog regeneration, and compile verification. Do not land placeholder component files or metadata-only entries

## Appendix: shadcn inventory reference

The tables below are research input captured for mapping purposes. They are not a build queue and carry no delivery commitment; an entry becomes work only when a Stage 2 or later slice names it

The inventory was captured on 2026-08-29 with shadcn CLI 4.19.0:

```sh
npx shadcn@latest search @shadcn --type ui --limit 100 --offset 0 --json
```

The command returned 61 `registry:ui` items and `hasMore: false`. Styles, examples, and `registry:block` entries are intentionally excluded. Re-run the command before consulting the mapping and review additions or removals explicitly

### Stage 1 mapping (built)

| shadcn item | Raw SwiftUI base | Registry implementation |
|---|---|---|
| `aspect-ratio` | Any `View` | Recipe: use native `.aspectRatio` directly; add no replacement type |
| `badge` | `Text` or `Label` | Focused badge modifier with semantic variants |
| `button` | `Button` | `ButtonStyle` variants for default, secondary, outline, ghost, destructive, and link treatments |
| `button-group` | `ControlGroup` | `ControlGroupStyle` or a group modifier using the same button variants |
| `card` | `GroupBox` | `GroupBoxStyle` for border, background, radius, and content spacing |
| `checkbox` | `Toggle` | Checkbox `ToggleStyle` while preserving the binding and control semantics |
| `input` | `TextField` and `SecureField` | `TextFieldStyle` for border, fill, focus, disabled, and invalid states |
| `label` | `Label` | `LabelStyle` variants for icon alignment and spacing |
| `progress` | `ProgressView` | Linear `ProgressViewStyle` and semantic tinting |
| `radio-group` | `Picker` | Recipe: apply `.pickerStyle(.inline)` for mutually exclusive options |
| `select` | `Picker` | Styled picker label and menu presentation |
| `separator` | `Divider` | Separator modifier for inset and orientation treatment |
| `slider` | `Slider` | Recipe: native slider with direct `.tint` and `.controlSize` where needed |
| `spinner` | `ProgressView` | Circular progress styling and sizing |
| `switch` | `Toggle` | Recipe: apply `.toggleStyle(.switch)` directly |
| `tabs` | `Picker` or `TabView` | Recipe: apply `.pickerStyle(.segmented)` for local tabs; retain `TabView` for app navigation |
| `textarea` | `TextEditor` | Focused editor modifier matching input states |
| `toggle` | `Toggle` | Button-like `ToggleStyle` variants |
| `toggle-group` | `Picker` or `ControlGroup` | Single-selection picker or multi-selection group using styled toggles |
| `native-select` | `Picker` | Recipe: apply `.pickerStyle(.menu)` distinct from the richer `select` presentation |
| `direction` | `EnvironmentValues.layoutDirection` | Recipe: semantic leading/trailing guidance; no visual replacement |

### Forms and data entry candidates

| shadcn item | Raw SwiftUI base | Possible native mapping |
|---|---|---|
| `calendar` | `DatePicker` and `MultiDatePicker` | Styled native calendar selection with single and multiple-date examples |
| `combobox` | `Picker`, `TextField`, `List`, and `.searchable` | Searchable selection composition with a binding and prepared options |
| `field` | `LabeledContent`, `Section`, `Label`, and content | Field layout composition for label, description, requirement, and validation message |
| `form` | `Form` | Form-level spacing and section treatment composed from styled fields |
| `input-group` | `TextField`, `Label`, and `Button` in a container | Leading and trailing accessory composition using Stage 1 input and button treatments |
| `input-otp` | `TextField` with one-time-code semantics | Accessible code-entry composition with a single binding and visual slots |
| `attachment` | `Label`, `Image`, `ProgressView`, and `Button` | Attachment composition with idle, uploading, processing, error, and completed states |

### Content and feedback candidates

| shadcn item | Raw SwiftUI base | Possible native mapping |
|---|---|---|
| `accordion` | `DisclosureGroup` | `DisclosureGroupStyle` for grouped expandable sections |
| `alert` | `Label`, `Text`, and optional `Button` | Inline alert composition with informational and destructive variants |
| `avatar` | `AsyncImage`, `Image`, or caller-provided content | Circular media composition with initials or symbol fallback |
| `breadcrumb` | `Button`, `Label`, and native navigation state | Compact hierarchy presentation for wide layouts; native back navigation remains authoritative |
| `collapsible` | `DisclosureGroup` | Single-region disclosure treatment distinct from grouped accordion styling |
| `empty` | `ContentUnavailableView` | Styled empty, search-empty, and recoverable-error content |
| `item` | `Label`, `LabeledContent`, `Button`, or `NavigationLink` | Row modifier for title, description, media, metadata, and actions |
| `kbd` | `Text` | Keycap modifier for keyboard shortcut hints |
| `marker` | `Label`, `Text`, and optional `Divider` | Muted annotation treatment with plain, separator, and bottom-border variants |
| `skeleton` | Any `View` with `.redacted(reason: .placeholder)` | Placeholder modifier that disables interaction and respects Reduce Motion |

### Presentation and navigation candidates (recipes by default)

| shadcn item | Raw SwiftUI base | Possible native mapping |
|---|---|---|
| `alert-dialog` | `.alert` or `.confirmationDialog` | Usage pattern with button roles and prepared copy; system appearance remains untouched |
| `context-menu` | `.contextMenu` | Styled `Label` actions and role guidance |
| `dialog` | `.sheet` or `.alert` | Dialog content modifier and sizing guidance |
| `drawer` | `.sheet` with presentation detents | Bottom-sheet content treatment using native drag and dismissal behavior |
| `dropdown-menu` | `Menu` | Styled menu trigger and native action labels |
| `hover-card` | `.popover` | Pointer and focus-triggered informational popover where the platform supports it |
| `menubar` | Toolbar `Menu` on iOS | Menu grouping and label treatment; do not emulate a desktop menu bar on iPhone |
| `navigation-menu` | `NavigationStack`, `NavigationSplitView`, and `Menu` | Navigation label and section treatments around native containers |
| `pagination` | `Button`, `Picker`, `TabView`, or paged `ScrollView` | Bound page-control composition with native scrolling where content is swipeable |
| `popover` | `.popover` | Styled popover content and compact-adaptation guidance |
| `resizable` | `NavigationSplitView` | Platform-owned column behavior; do not recreate browser drag handles on iPhone |
| `scroll-area` | `ScrollView` or `List` | Content margins, indicators, clipping, and edge treatment modifiers |
| `sheet` | `.sheet` | Styled sheet content with native detents, drag indicator, and dismissal |
| `sidebar` | `NavigationSplitView` and `List` | Sidebar row and section styles using native selection and collapse behavior |
| `tooltip` | `.help`, `accessibilityHint`, and optional informational popover | Platform-adapted help without hover-only information |

### Complex interactive candidates

| shadcn item | Raw SwiftUI base | Possible native mapping |
|---|---|---|
| `carousel` | Horizontal `ScrollView` with paging behavior | Generic paging composition with native scrolling, indicators, and Reduce Motion support |
| `chart` | Swift Charts `Chart` | Shared chart foreground, axis, legend, and tooltip treatments; chart semantics stay domain-specific |
| `command` | `TextField`, `List`, `.searchable`, and `.sheet` | Command palette composition with caller-provided commands and actions |
| `sonner` | Overlay, `Label`, and `Button` | Transient status presenter with queued messages, dismissal, and accessibility announcements |
| `table` | `Table`, `Grid`, or `List` | Header, row, selection, and compact-adaptation treatments around native containers |

### Messaging candidates

| shadcn item | Raw SwiftUI base | Possible native mapping |
|---|---|---|
| `bubble` | `Text`, caller content, and container modifiers | Aligned message bubble with default, secondary, muted, tinted, outline, ghost, and destructive treatments |
| `message` | `HStack`, `VStack`, avatar content, and bubble content | Message composition for alignment, avatar, header, body, and footer |
| `message-scroller` | `ScrollView` and `ScrollPosition` | Message viewport with bottom anchoring, new-message preservation, and scroll-to-edge control |

### Block candidates

1. Authentication form: `card`, `input`, `button`, inline validation feedback (Stage 2)
2. Settings section: switches, selection, `separator`, destructive actions (Stage 2)
3. Data table screen: `table`, `pagination`, `dropdown-menu`, `badge`, `skeleton`, `empty`
4. Command search: `command`, `dialog`, `input`, `item`, `kbd`, `empty`
5. Chat screen: `message-scroller`, `message`, `bubble`, `attachment`, `input-group`, `button`
6. Dashboard: `card`, `chart`, `tabs`, `select`, `table`, `badge`

A block does not introduce a new foundation token, component variant, or helper abstraction unless at least two real usages prove the need
