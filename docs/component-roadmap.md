# Component roadmap

## Goal

Deliver valuable native SwiftUI product workflows as source-owned blocks, then extract only the reusable seams those workflows prove. The shadcn catalog is research input, not a build queue: stages are vertical product slices, not component-count parity, per the committed direction review (`GENERAL_DIRECTION_REVIEW.md`, "Roadmap changes")

A component does not replace a native control. `Button`, `TextField`, `Toggle`, `Picker`, `Menu`, `ProgressView`, `ScrollView`, `NavigationStack`, and system presentations remain visible at the call site. The registry standardizes them with SwiftUI style protocols, focused `ViewModifier`s, semantic theme values, and small compositions where one primitive is insufficient

## Current state

Updated 2026-09-06. This section and the per-stage Status lines are the only home of stage status; status text in any other file is a pointer here

- Stage 1: complete, closed 2026-08-31 with findings F-001 through F-024 resolved (`STAGE_ONE_VALIDATION.md`)
- Stage 1.5: complete. The clean-room trial ran 2026-08-31 and all six recorded defects were fixed the same day (`docs/clean-room-trial.md`)
- Stage 2: complete 2026-09-01, exit evidence recorded in its section below; the seam extraction verdict was 0 of 7, nothing shared
- Stage 3: complete 2026-09-05. The activity feed is the one coherent screen; it named alert, avatar, skeleton, empty, accordion, and item, and the finance block adopted the empty-state treatment as its second consumer. Eleven presentation and navigation recipes landed alongside. Exit evidence is recorded in its section below
- Foundations grew on 2026-09-05 into the set-up-once contract: `accent` and `onAccent` tokens, `compactRadius`, six presets, and a root `registryTheme(_:)` that also applies the tint. No tag exists yet, so `0.1.0` remains the first published contract and now means this shape
- Showcase is a browsable catalog (Components, Blocks, Recipes) with a generated manifest, a demo per item, a capture launch route, and the theme tuning panel kept beside the catalog since 2026-09-05: an accent strip above the tab bar, a sheet the catalog stays interactive under on iPhone, a trailing column on iPad, with Copy Swift, Copy Code, and Import
- Stage 5 (done 2026-09-06): the theme preview wall, shadcn's 68 create-page cards and their five missing primitives, delivered in eight serial slices; the `theme-preview` capture route, the Showcase's `preview` and `preview-02` block demos, the Create page, and the Themes page all show the wall. The card list and exit evidence are in its section below
- Preset codes (2026-09-05): a `RegistryTheme` as one short string that the website's Create page (`/create`), the Showcase panel, `swiftui-registry preset` (RegistryKit's `Preset.swift`, the reference since Stage 6), and the MCP server's `describe_preset` and `apply_preset` all read and write (`docs/registry-spec.md`, "Preset codes"); `swiftui-registry preset apply` writes `RegistryTheme+App.swift` for a consumer, `capture_previews.py --preset` renders any code on the pinned simulator, and `Registry/preset_vectors.json` pins the codes all three codecs reproduce
- The website is a Next.js static site built with shadcn/ui under `Website/`, fed by generated `content/registry.json`, with a page per item and a Themes page, deployed 2026-09-05 to Cloudflare Workers at https://swiftui-registry.mangobytekw.workers.dev; `docs/images/items/` and `docs/images/themes/` hold the light and dark captures
- Stage 4 (2026-09-05): the command and search screen, `command-search`, named `input-group`, `kbd`, and `command`; status and evidence in its section below
- First consumer outside `Examples/Showcase`: the seeFood app installed settings-section, select, separator, button, and input on 2026-09-01 through a local path dependency, with the receipt in its destination; the published URL remains unexercised because no tag exists
- Audit (2026-09-05): every canonical file, the foundations, and the Showcase harness were reviewed against SwiftUI best practice; 18 commits fixed the verified findings and the rest are owner decisions. Findings, evidence, and the closing count are in the Audit section below
- Placement rule for presentation choices (2026-09-06): the three composed views that carried a presentation choice in their initializer (`InlineAlert` variant, `TransactionRow` tone, `MacroProgress` tint) now take it as a `registry`-prefixed copy-and-return method (`registryVariant`, `registryTone`, `registryTint`); the rule is written in `AGENTS.md` and `docs/architecture.md`, and this closes the matching open deferral
- Stage 6: complete 2026-09-06. The `swiftui-registry` tool (RegistryKit) is the only installer, validator, search, preset codec, MCP server, and generator; the Python path is gone; outside a clone the tool fetches the pinned `0.1.0` snapshot on first use; the release workflow and Homebrew formula template are in place. Phase evidence is in the Stage 6 section below, and the owner's publishing steps are under Open deferrals
- Current catalog counts and per-item pages live in the generated `docs/catalog/index.md` and the website, not in prose here

### Open deferrals

Standing debt already on record. A done-claim that touches one of these areas names it

- iOS 26 runtime evidence: no iOS 26 simulator runtime is installed, so the floor is verified by compilation and the iOS 27 runtime only
- The `0.1.0` tag exists locally (2026-09-05) and is not pushed, so the published URL still resolves nothing until the owner pushes it (`docs/registry-spec.md`). The site has no custom domain yet; `.github/workflows/pages.yml` remains as an alternative deploy path
- Stage 6 publishing is the owner's sequence (2026-09-06): push `main` and the `0.1.0` tag (the tag also makes the tool's snapshot download resolve; it answered HTTP 404 on 2026-09-06), publish the GitHub release so `release.yml` uploads the universal binary and its `.sha256`, create `mangobyte-dev/homebrew-tap` with `Distribution/homebrew/swiftui-registry.rb` as `Formula/swiftui-registry.rb` carrying that checksum, tag the tap `swiftui-registry-0.1.0`, then document `brew install mangobyte-dev/tap/swiftui-registry` in the README, the catalog index, and the website. The CI workflows on `macos-26` have not run either; the first push is their evidence
- Visual threshold coarseness: the 2 percent tolerance at 96 by 192 absorbed a whole tab-bar change once (`docs/visual-testing.md`, GOLDEN-CHANGE 2026-09-01)
- seeFood's theme bridge compiles unchanged against the 2026-09-05 foundations (every new initializer argument has a default) but does not yet set `accent` or `onAccent`; adopting them is that app's decision
- Reduce Motion, VoiceOver announcement timing, and the accordion's rotation are verified structurally and on the simulator, not on a device
- Two visual references are stale after the tuning panel left its tab (2026-09-05): `auth-light` (2.67 percent; it was already stale after the audit) and `nutrition-light` (1.53 percent) because their blocks reach the accent strip that now sits above a three-tab bar; the other four references absorb the strip within tolerance (`docs/visual-testing.md`, GOLDEN-CHANGE pending). This supersedes the three stale references from the audit. Replacing them from the reviewed attachments is the owner's action (`HANDOFF.md` names the commands); the other 17 UI tests and the 7 Showcase unit tests pass
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
10. MCP adapter over the registry JSON (search, plan, install) for agents inside consuming apps. Status: done 2026-09-05; `Scripts/mcp_server.py` was a dependency-free stdio server tested end to end over JSON-RPC, replaced byte for byte by `swiftui-registry mcp` in Stage 6 Phase B and removed in Phase C
11. A Swift CLI so adopters do not need Python. Owner decision 2026-09-06: Stage 6 rewrites the whole Python path (installer, validator, receipts and merge, search, presets, MCP, and generators), with command parity and the same receipts on disk as the exit criteria. Status: done 2026-09-06 with Stage 6 Phase C; the exit criteria were proven by the 1,184-comparison oracle in Phases A and B, and Phase C removed the Python consumer path, so there is one installer. Phase D added the pinned snapshot cache, the release workflow, and the formula template; publishing is the owner's step
12. Usage-snippet compile proof for installable items independent of the Showcase demos. Status: closed 2026-09-05: snippets reference caller state (`$email`, `rows`, `onSelect`) that a generic wrapper cannot supply without per-item fixtures, which would duplicate the demos; the demos remain the compile proof and the walk proves each exists
13. iOS 26 simulator runtime for floor evidence. Status: open, needs a multi-gigabyte download on the owner's machine
14. Custom domain for the Worker plus `X-Robots-Tag: noindex` on the workers.dev host. Status: open, needs the owner's domain
15. Stage 4: a command and search screen naming `command`, `kbd`, and `input-group`. Status: done 2026-09-05; evidence in the Stage 4 section
16. Create page and preset codes, the registry's counterpart of shadcn's `/create` and `--preset`. Status: done 2026-09-05. One codec in three languages (`Scripts/preset.py` the reference, `Website/lib/preset.ts`, the Showcase's `ThemePreset.swift`) with 26 pinned vectors checked by `test_preset.py` (Python and, through Node, TypeScript) and the Showcase package's `ThemePresetTests` (7 tests, run by the app scheme); since Stage 6 the reference is RegistryKit's `Preset.swift`, the vectors live in `Registry/preset_vectors.json`, and `PresetTests.swift` and `PresetContractTests.swift` check them; `preset.py decode | url | apply | resolve | random`, with `apply` refusing to replace an edited theme file; MCP `describe_preset` and `apply_preset`; the website `/create` page with the token board, the six preset captures, the Swift, the apply commands, Open, Random, Reset, and a shareable `?preset=` URL; the Showcase's Copy Code, Import of a code, `-preset <code>` launch, and `capture_previews.py --preset`. A mutation pass over the Python codec, CLI, and MCP tools killed all 18 mutants after three survivors were fixed (a misplaced test method, a dead parse branch, an untested MCP `force` check)
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
- Unified validation: `Scripts/registry_validation.py` is the single structural validator used by install, search, `Scripts/validate.py`, catalog generation, and CI tests (since Stage 6 Phase C: `Sources/RegistryKit/Validation.swift` behind `swiftui-registry validate`)
- Inspectable install: `Scripts/install.py --plan` prints the ordered closure, per-target statuses, package requirements, collisions, and manual integration steps without writing; `--diff` audits owned source against canonical registry source (since Stage 6 Phase C: `swiftui-registry install --plan` and `--diff`)
- Actionable package metadata: every version requirement carries a `sourceURL` and a machine-resolvable `swiftPM` rule, with the compatibility policy in `docs/registry-spec.md`
- Generated per-item documentation: `docs/catalog/` is generated from metadata by `Scripts/generate_catalog.py` (since Stage 6 Phase C: `swiftui-registry generate catalog`), each page leading with preview, install command, and a `usage` snippet, with recipes leading with the snippet because nothing installs; a freshness test keeps it byte-identical to the metadata
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

Status: done 2026-09-06. Slice 1 (the `field`, `chart`, `table`, `combobox`, `breadcrumb` primitives) is on main; slice 2 (the `preview` block with cards 1 to 11: activate-agent-dialog, analytics-card, anomaly-alert, assign-issue, bar-chart-card, bar-visualizer, book-appointment, codespaces-card, contributions-activity, contributors, environment-variables), slice 3 (cards 12 to 22: feedback-form, file-upload, github-profile, icon-preview-grid, invite-team, invoice, live-waveform, no-team-members, not-found, observability-card, pie-chart-card, with third-party brand copy neutralized across the wall), and slice 4 (cards 23 to 33: report-bug, shipping-address, shortcuts, skeleton-loading, sleep-report, style-overview, typography-specimen, ui-elements, usage-card, visitors, weekly-fitness-summary, which finishes the 33-card block and bumps it to 0.3.0) are done 2026-09-06; slice 5 (the `preview-02` block created at 0.1.0 with cards 1 to 12: account-access, album-card, card-overview, catalog-toolbar, claimable-balance, contribution-history, cover-art, dividend-income, empty-connect-bank, empty-distribute-track, empty-explore-catalog, faq) is done 2026-09-06; slice 6 (the `preview-02` block's cards 13 to 24: front-door, index-investing, kitchen-island, loading-card, new-milestone, notification-settings, payments, payout-threshold, power-usage, preferences, qr-connect, receiving-method, which bumps the block to 0.2.0) is done 2026-09-06; slice 7 (the `preview-02` block's cards 25 to 35: recent-transactions, release-catalog, roller-shades, savings-progress, savings-targets, sidebar-nav, social-links, stock-performance, syncing-state, transfer-funds, upcoming-payments, which finishes the 35-card block and bumps it to 0.3.0) is done 2026-09-06. Owner's instruction: recreate every element shadcn's `/create` page shows while a theme is being composed, so the Showcase's tuning panel and the website's Create page preview a wall of realistic product UI instead of one strip

What shadcn shows: its create page previews two registry blocks, `preview` (33 cards) and `preview-02` (35 cards), each a seven-column masonry of cards built from the ui primitives (`apps/v4/registry/bases/base/blocks/preview*/cards/*.tsx` in shadcn-ui at 7c9eaba). Measured against this registry on 2026-09-05, the primitives those 68 cards use are all present as components or recipes except five: `field` (20 cards), `chart` (11 cards, Swift Charts), `combobox` (2), `table` (2), and `breadcrumb` (1)

Delivery, one serial slice per Opus 4.8 worker run, each slice a dependency-closed unit (source, metadata with usage and accessibility, preview, demo, captures, generators, tests, compile, one commit per item or block):

1. Primitives: `field`, `chart`, `table`, `combobox`, `breadcrumb`. Native controls stay visible; each earns its place under the value gate or ships as a recipe
2. Block `preview`, cards 1 to 11: activate-agent-dialog, analytics-card, anomaly-alert, assign-issue, bar-chart-card, bar-visualizer, book-appointment, codespaces-card, contributions-activity, contributors, environment-variables
3. Block `preview`, cards 12 to 22: feedback-form, file-upload, github-profile, icon-preview-grid, invite-team, invoice, live-waveform, no-team-members, not-found, observability-card, pie-chart-card
4. Block `preview`, cards 23 to 33 plus the block itself: report-bug, shipping-address, shortcuts, skeleton-loading, sleep-report, style-overview, typography-specimen, ui-elements, usage-card, visitors, weekly-fitness-summary; the masonry layout, metadata, demo, iPhone and iPad captures (done, 2026-09-06: all 33 cards render in the Showcase; the compact wall became a non-lazy `VStack` so `testEveryRegistryItemHasADemoInTheCaptureRoute` covers every card on the pinned iPhone and passes with zero unlabeled controls, after the one it flagged, the native switch in ui-elements, was given `labelsHidden` and an explicit accessibility label; iPhone `preview-{light,dark}.png` and iPad `preview-ipad-{light,dark}.png` captures regenerated; block bumped to 0.3.0)
5. Block `preview-02`, cards 1 to 12: account-access, album-card, card-overview, catalog-toolbar, claimable-balance, contribution-history, cover-art, dividend-income, empty-connect-bank, empty-distribute-track, empty-explore-catalog, faq (done, 2026-09-06: the `preview-02` block was created at 0.1.0 with these first 12 cards, translated from shadcn's second create-page preview; album-card and cover-art draw themed placeholders instead of images, card-overview, contribution-history, and dividend-income use registryChart() on Swift Charts, catalog-toolbar uses input-group and toggle-group, faq pairs a segmented Picker with the accordion style, and all third-party brands are neutralized. The compact wall is a non-lazy VStack, so `testEveryRegistryItemHasADemoInTheCaptureRoute` audits every card on the pinned iPhone and passes with zero unlabeled controls, no fixes required. iPhone `preview-02-{light,dark}.png` captured; slices 6 and 7 append the remaining 23 cards)
6. Block `preview-02`, cards 13 to 24: front-door, index-investing, kitchen-island, loading-card, new-milestone, notification-settings, payments, payout-threshold, power-usage, preferences, qr-connect, receiving-method (done, 2026-09-06: the twelve cards were appended to the wall in order and the block bumped to 0.2.0, one commit per card. front-door and qr-connect draw deterministic `Canvas` placeholders (a diagonal-stripe camera view and an illustrative QR module grid from a fixed bit pattern) instead of images; loading-card wraps real content in the registry skeleton; notification-settings uses the registry checkbox with a multi-source `Toggle` for the mixed select-all; payments pairs the registry Breadcrumb with a native Menu; payout-threshold uses the registry select on a Picker, a native Slider, and the registry text area; power-usage uses registryChart() on Swift Charts and the registry linear progress; kitchen-island and its scene selector use native Slider, Toggle, and a segmented Picker; receiving-method's radio group is a native inline Picker; index-investing offers its link as a registry link button because SwiftUI has no inline text link without a real URL; new-milestone uses a native DatePicker; the skeleton, checkbox, breadcrumb, select, textarea, and progress registry dependencies were added and all third-party brands neutralized. The compact wall stays a non-lazy VStack, so `testEveryRegistryItemHasADemoInTheCaptureRoute` audits every card on the pinned iPhone: it first flagged the two preferences switches as unlabeled native switches, which were relabeled with the labelsHidden-plus-explicit-accessibilityLabel recipe (the kitchen-island idiom) so each switch carries its own label, and the re-run passes with zero unlabeled controls. iPhone `preview-02-{light,dark}.png` recaptured; slice 7 appends the remaining 11 cards)
7. Block `preview-02`, cards 25 to 35 plus the block itself: recent-transactions, release-catalog, roller-shades, savings-progress, savings-targets, sidebar-nav, social-links, stock-performance, syncing-state, transfer-funds, upcoming-payments (done, 2026-09-06: the eleven cards were appended to the wall in order and the block bumped to 0.3.0, one commit per card, so the finished `preview-02` wall now holds 35 cards. recent-transactions uses the registry DataTable with a native per-row Menu; release-catalog pairs an input-group search with a toggle-group filter over ItemRow holdings; roller-shades keeps a native Slider and a segmented Picker; savings-progress draws a registryChart() SectorMark donut with a plot-area readout, and stock-performance a registryChart() AreaMark with a Combobox in a Field; savings-targets and transfer-funds compose Field, InputGroup, the registry select on a native Picker, and muted registry-surface summaries, with savings-targets adding the registry linear progress; sidebar-nav is a native List with sections and a selection binding on the registry surface, not a NavigationSplitView; social-links pairs Field with InputGroup; syncing-state puts the registry spinner in a ContentUnavailableView; upcoming-payments pairs a native graphical DatePicker with ItemRow payments and badges. The table, combobox, and spinner registry dependencies were added and all third-party brands neutralized. The compact wall stays a non-lazy VStack, so `testEveryRegistryItemHasADemoInTheCaptureRoute` audits every card on the pinned iPhone: it passed with zero unlabeled controls and no fixes required. iPhone `preview-02-{light,dark}.png` recaptured, and the iPad wall captured to `docs/images/blocks/preview-02-ipad-{light,dark}.png`.)
8. Wire-up: the `theme-preview` capture route and the website's Create page render the `preview` wall, the preset captures regenerate, and the docs record the stage (done, 2026-09-06: `ItemDemos`'s `theme-preview` case renders `PreviewWall` and `TuningPreview` was deleted; the six presets were recaptured to `docs/images/themes/` and the site data regenerated; the Themes and Create pages now call each preset capture the wall's first screen and link to `/items/preview/`; this section and the exit-criteria evidence below record the stage as done)

Rules that bind every slice: `AGENTS.md` in full; a card composes registry items and native controls with sample data, never a wrapper that renames an Apple control; charts use Swift Charts; the animated visualizers use `TimelineView` and `Canvas`; nothing is pushed; visual references are never regenerated to pass a test

### Stage 5 exit criteria

- Every one of the 68 cards renders in the Showcase under all six presets and both appearances, and the two blocks install through `Scripts/install.py` with their closures
- The five primitives have metadata, previews, demos, captures, and accessibility notes like every other item
- The Create page shows the wall for the six presets, and the tuning panel's preview on device is the same wall

### Stage 5 exit-criteria evidence (2026-09-06)

The wall is two blocks totaling 68 cards: `preview` (block, 0.3.0, 34 source files, 33 cards plus `PreviewWall`) and `preview-02` (block, 0.3.0, 36 source files, 35 cards plus `PreviewWall02`), 33 plus 35. The `theme-preview` capture route now renders `PreviewWall`, so `docs/images/themes/{system,graphite,indigo,rose,emerald,amber}-{light,dark}.png` were recaptured on the pinned light-mode iPhone 17 iOS 27.0 simulator with `-AppleLanguages (en) -AppleLocale en_US`. The first screen of each shows the activate-agent-dialog, analytics, and anomaly-detection cards under that preset: the default blue tint under system, the ink-on-paper black accent under graphite, and the amber accent with its dark on-accent label under amber, with English month labels and USD. `python3 Scripts/capture_previews.py --preset a13GkaOXWwIa` renders the same amber wall

Both blocks install with their full closures. `python3 Scripts/install.py preview --plan --destination /tmp/registry-plan-check` resolves a 23-item closure (22 components plus the block), writes 56 files, and exits 0; the same for `preview-02` resolves a 24-item closure (23 components plus the block), writes 59 files, and exits 0. Every card was audited for accessibility by `testEveryRegistryItemHasADemoInTheCaptureRoute`, which walks the non-lazy compact wall on the pinned iPhone; slices 4 through 7 record it passing with zero unlabeled controls on every card of both walls. The five primitives ship like any other item, with versions `field` 0.1.0, `chart` 0.1.1, `table` 0.1.0, `combobox` 0.1.0, and `breadcrumb` 0.1.0, each carrying metadata, a preview, a demo, captures, and accessibility notes

The Create page and the Themes page show the wall's first screen per preset from those captures, and the CSS token board stands in for a code that matches no preset (`Website/components/create-studio.tsx`, `Website/app/themes/page.tsx`). On device the browsable `preview` block demo is `PreviewWall` itself (`BlockDemos.PreviewDemo`), so the tuning panel, kept beside the catalog, previews the same wall live over it

## Stage 6: Swift command-line rewrite

**Status: Complete 2026-09-06 (Phases A through D); the publishing steps are the owner's, under Open deferrals**

The owner requested one phase per pull of work. Phase A supplies the engine and consumer commands; Phase B adds MCP and the three generators, Phase C removes the consumer Python path and changes documentation, website commands, and CI, and Phase D supplies cached release snapshots and distribution. `Scripts/capture_previews.py` remains Python because it automates simulator captures and has no consumer role

### Phase A evidence (2026-09-06)

Local commit: `4746b66 Implement Stage 6 Phase A registry engine and consumer commands`, based on `0d353ed`. It has not been pushed

The root package has a SwiftUI-free `RegistryKit` library and a `swiftui-registry` executable. `validate`, `search`, all five install modes, and `preset decode | url | apply | resolve | random` use Swift implementations. `SwiftUIRegistryFoundations` and all Showcase source remain unchanged. `docs/cli-migration.md` records the dependency, codec-sharing, effect, and diagnostic decisions

`Scripts/check_swift_parity.py` passed 794 real subprocess pairs against a temporary registry clone. It compared stdout, stderr, exit status, and complete destination trees, including receipts, source digests, installed digests, base paths, base bytes, and conflict artifacts. It exercised every catalog item, the search filters, every preset vector, negative and large random seeds, unknown items, both directions of Python and Swift receipt interoperability, clean merges, conflicted updates, and force cleanup. It normalizes temporary destination paths in output only; file bytes are compared directly

The RegistryKit Swift Testing suite passed 18 tests, including 45 captured validator cases from the unchanged Python suite, 106 Python unified-diff cases, all 26 shared preset vectors, receipt damage, missing bases and targets, symlink escape, untracked collision, recipe refusal, and full-closure conflict preflight. Inline snapshots pin command output and complete directory trees after installation, a clean merge, and a conflict. The console dependency captures the real command output without redirecting the test runner's descriptors

`swift build`, `swift test --filter RegistryKitTests`, and `swift build -c release` passed with Swift 6.4. Both validators passed. All 106 Python tests remain green. The three Python generators regenerated with no tracked output changes. `make format-check` passed. Showcase built on the pinned iPhone 17 simulator; the build emitted one AppIntents metadata-extraction warning because it has no AppIntents.framework dependency, with no Swift compiler warnings or errors

Not run: the Showcase UI suite and captures, because no Showcase or registry UI source changed; the website typecheck and build, because no website source changed. The existing auth-light and nutrition-light references remain untouched. The package's new executable is a macOS tool, not a new supported platform claim for registry items

### Phase B evidence (2026-09-06)

`RegistryKit` now owns the seven MCP tools and all three generators. `MCPServer.swift` calls the same installer, search, and preset operations as the consumer commands. `RegistryInput` and `RegistryConsole` supply stdio effects; home expansion belongs to the filesystem dependency. `OrderedJSON` preserves insertion order and preset numeric spelling without changing sorted receipt and search output. No package dependency was added

The complete subprocess oracle passed 1,184 comparisons: the original 794 consumer-command pairs plus 390 Phase B comparisons. Phase B checks all catalog items through describe, plan, install, repeat install, and diff; all preset vectors through describe and apply; protocol negotiation, notification silence, parse errors, invalid arguments, recipes, edited-source and theme refusals, and forced replacement. It compares exact JSON-RPC wire bytes, including nested formatted text, and complete destination trees. Two persistent-process comparisons keep stdin open and prove responses arrive before EOF and metadata edits are reloaded

The three generator comparisons include every catalog page, stale Markdown cleanup, preservation of unrelated files, both Showcase manifests, website JSON, and all 142 copied images. Both Python and Swift regenerated the repository outputs with no tracked drift. Templates and generated command examples intentionally still mention Python so Phase B changes no published bytes

The unchanged `test_mcp_server.py` passed all four tests against the Swift subprocess. The external harness substitutes only `[sys.executable, str(SERVER)]` with the built binary, `mcp`, and the explicit registry root; the test file and its assertions are unmodified

`swift build`, `swift build -c release`, and `swift test --filter RegistryKitTests` passed with 23 Swift tests. New tests pin all seven successful MCP responses as inline wire snapshots, protocol refusals, real generator command output, in-memory metadata reload and home expansion, source and usage contracts for generated pages, and full byte-equality drift. All 106 Python tests, both validators, `make format-check`, and whitespace checks passed

The Showcase and website source and generated bytes are unchanged, so their builds, UI suite, and captures were not repeated. `auth-light` and `nutrition-light` references remain untouched. Phase C still owns Python removal, remaining source-contract test ports, command migration, and CI; Phase D still owns the cache and distribution

### Phase C evidence (2026-09-06)

Local commit: `3e5b53c Implement Stage 6 Phase C Python removal and command migration`, based on `41c2bd8`. It has not been pushed

The Python consumer and publishing path is gone. The nine consumer modules under `Scripts/` (`validate`, `install`, `search`, `preset`, `mcp_server`, `registry_validation`, and the three generators), the parity script `check_swift_parity.py`, and `Tests/RegistryTests/` with its 106 test methods were deleted. `Scripts/capture_previews.py` remains Python and now lists items, validates the registry, and checks a preset code through the built `swiftui-registry` tool (`--tool <binary>`, or a release build of this clone); it imports nothing from the removed modules

The shared preset vectors moved to `Registry/preset_vectors.json`. Every reader follows: the RegistryKit fixture byte check, the Showcase package's `ThemePresetTests` (by path), the TypeScript checker (now `Tests/RegistryKitTests/Fixtures/preset-vectors-check.ts`, driven by `websiteCodecReproducesEveryVector` under Node 22's `--experimental-strip-types`), the UI suite comment, `Website/lib/preset.ts`, and the documents

Every remaining Python assertion is represented in Swift. 26 tests joined the suite, 49 in all: `RegistryContractTests.swift` (native seams for button, badge, button-group, and card; schema field coverage and the recipe conditional's `kind` gate; `#Preview` names; the Stage 1 seams, adaptive previews, and interaction states read from the roadmap table; the value gate's recipe set and counts; recipe refusal, plan, and exit 2; the textarea, aspect-ratio, slider, and invalid-color contracts; every token's two consumers; the Showcase's exact installed bytes; block resolution order and the auth and settings contracts; receipt provenance for `finance-overview`, the package instruction, the clean refusal naming `--diff`, `--update`, and `--force`, diff hunks, the locally-modified receipt surviving plain installs, block plan output, plan statuses including `updated`, and search ranking, floors, JSON fields, and aliases), `MCPContractTests.swift` (over the real catalog: `tools/list`, alias search, version negotiation, plan without writing, install closure, up-to-date, diff, ownership refusal, recipe guidance, and the preset tools' describe, apply, invalid code, and `force` type errors), and `PresetContractTests.swift` (the 61-bit budget against the vector document, accent validation and grid snapping, the Tune-panel spellings, theme-file round trips, the dual custom accent, the labeled subset, the UIKit import, the website codec, and the CLI apply, resolve, refusal, decode, url, and random flow). The catalog `index` refusal, determinism, manifest usage, and site-data checks were already in `GeneratorTests.swift`; the validator cases in `validation-cases.json`; the receipt's empty `packageDependencies` in the `Commands` snapshot

Published bytes changed as the checkpoint required, in the Swift templates first: all 57 catalog pages and the index now say `swiftui-registry install <name> --destination Sources/YourFeature/Components`, the two Showcase manifests carry a `swiftui-registry generate showcase-manifest` header, the plan's third next step and the theme file's comment name the tool, and the Showcase detail screen, the website's hero, item pages, Create page, and Themes page print the same commands. `Website/content/registry.json` is unchanged because the site builds the install command in `Website/lib/registry.ts`. Decision: published examples spell the tool `swiftui-registry <command>`; from a clone that is `swift run swiftui-registry <command>`, or `.build/release/swiftui-registry` on PATH with `--registry <clone>`. Phase D's Homebrew formula gives the bare spelling its install path

CI no longer installs Python. The registry gate runs on GitHub's `macos-26` image (default Xcode 26.6 per the `actions/runner-images` README read 2026-09-06; the package declares Swift tools 6.2): `swift build`, `validate`, the three generators, the committed-output diff, `swift test` after `setup-node` 22 for the codec check, and `make format-check`. The website job and the Pages workflow generate site data with the tool on the same image. No push has run these workflows yet, so their first green run is the owner's evidence

Documents updated: `AGENTS.md` (the RegistryKit boundary, the single validator path, the generator rule, the verification list and its scoping, the CI pin), `docs/registry-spec.md`, `docs/architecture.md`, `docs/cli-migration.md`, `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, the pull request template, the Showcase and website READMEs, the fixture README, and `HANDOFF.md`. Archive references were classified and left as history: `STAGE_ONE_VALIDATION.md`, `GENERAL_DIRECTION_REVIEW.md`, `docs/clean-room-trial.md`, `tasks/`, and the dated Backlog, Stage 2, Stage 5, and Audit records in this roadmap. `docs/visual-testing.md`, `docs/research.md`, and `Website/components/item-preview.tsx` mention only the capture script, which remains Python

Verification: `make format`, `swift build`, `swift test` (5 Foundations tests and 49 RegistryKit tests, no compiler warnings), `swift build -c release` (no warnings), `validate` (full catalog passed), the roadmap's search example, both Showcase installs (no tracked change), the three generators (58 catalog pages and both manifest headers changed exactly as above, then no further drift), `make format-check`, `git diff --check`, and in `Website/` `npm ci`, `npm run typecheck`, `npm run lint`, and `npm run build` (63 static pages) all passed. The Showcase built for the pinned iPhone 17 with no Swift compiler warnings (only the AppIntents metadata-extraction notice recorded in Phase A), its 7 package unit tests passed against the moved vectors, and the UI suite ran once with the explicit destination: 19 tests, 17 passed, and the two known stale references failed as before, `auth-light` at 2.69 percent (2.67 before this phase; its screen shows the changed install command) and `nutrition-light` at 1.53 percent (unchanged). No reference was replaced; the result bundle is `/tmp/swiftui-registry-stage6-c-showcase-tests.xcresult`. The `settings-light` reference, whose screen ends with the install command, stayed within tolerance

Not run: captures, because no item's look changed. Backlog item 11 closes with this phase: adopters need no Python, and the command parity and on-disk receipt exit criteria were proven by the Phase A and B oracle before its removal. Phase D remains for the release snapshot cache and distribution

### Phase D evidence (2026-09-06)

Phase D is the implementation unit titled `Implement Stage 6 Phase D release snapshot cache and distribution`, based on the Phase C commits; consult git for its hash. It has not been pushed

The tool works from any directory. `LocalRegistrySource` resolves `--registry <path>` first, then the nearest enclosing clone, then `ReleaseSnapshot`: the GitHub tag archive of the pinned `RegistryRelease.version` (`0.1.0`, the same constant behind `--version` and the MCP `serverInfo`), unpacked by `tar --strip-components=1` into `~/Library/Caches/swiftui-registry/registries/0.1.0/` beside a `snapshot.json` manifest that records the version, the URL, and the injected clock's `fetchedAt`. A valid cache (manifest version and `Registry/registry.json` present) serves every command without a request; `--refresh` downloads into a staging directory, replaces the cache only after the archive proved to hold a registry, and rewrites the manifest; a failed download or unpack removes the staging directory, keeps the previous cache, and exits 2 naming the URL, the cause, and `--registry`. `--refresh` reaches only the cache and the update stamp; `install --force` reaches only owned source; both may be combined; neither the override nor a clone is affected by `--refresh`. The fetch is announced on stderr. The download, unpack, and tags requests are dependencies (`RegistryDownloader`, `RegistryArchive`, `ReleaseTags`) whose test values throw, so no test reaches the network by accident; the live downloader uses an ephemeral `URLSession` so URLCache never writes into the tool's cache directory or remembers a 404

The newer-release notice follows pfw at `854b491` (`Sources/pfw/Install.swift`, `Dependencies/GitHub.swift`): after a successful `install` or `install --update`, the tags of `mangobyte-dev/homebrew-tap` are read from the GitHub tags API, the first `swiftui-registry-` tag is compared with the running version, and `swiftui-registry <version> is available. Run 'brew update && brew upgrade swiftui-registry' to install.` is printed when they differ; any failure is silent. The one deliberate difference is the clock: `~/Library/Caches/swiftui-registry/update-check.json` stamps `checkedAt` and the latest tag, and the tap is asked at most once a day unless `--refresh` is passed; `--plan` and `--diff` never ask. `validate` now routes registry resolution through the same refusal path as every other command, so a snapshot failure exits 2 instead of ArgumentParser's generic 1

Distribution follows pfw's `release.yml`: `.github/workflows/release.yml` builds `swift build -c release --arch arm64 --arch x86_64` on `macos-26` when a GitHub release is published, then uploads `swiftui-registry-macos-universal.tar.gz` and its `.sha256` to that release with `gh` under `contents: write`. `Distribution/homebrew/swiftui-registry.rb` is the formula template for `mangobyte-dev/homebrew-tap`; it evaluates under Homebrew 6.0.21's Ruby (`Formulary.class_s("swiftui-registry")` is `SwiftuiRegistry`; the class loads with the expected name, version, URL, and description), with a zero checksum the owner replaces from the uploaded `.sha256`. `brew install` is not documented anywhere until the tap exists, per the Phase D gate

Tests: `SnapshotTests.swift` adds 7 tests (56 RegistryKit tests in all): the override and an enclosing clone win without any request, a first command fetches once and every later command reuses the cache while `--refresh` fetches again and rewrites the manifest with the new clock reading, a cache whose manifest names another version or lacks the index is replaced, download and unpack failures are readable and leave no staging or partial cache, the notice follows the tags and the 24-hour throttle (six installs across nine simulated days: notice, stamp reuse, re-request after a day, `--refresh`, an unrelated tag recording `null`, a silent failure, and a plan that never asks), the live tar extractor strips the tag directory and reports bad input, and the live downloader reads file URLs and reports failures. The in-memory filesystem gained a settable working directory and directory renames for these tests

Verification: `make format`, `swift build`, `swift test` (5 Foundations and 56 RegistryKit tests, no compiler warnings), `swift build -c release` (no warnings), `make format-check`, and `git diff --check` passed. Live, from `/private/tmp` with no clone: `validate` announced the fetch on stderr and exited 2 with `HTTP 404 from https://github.com/mangobyte-dev/swiftui-ui-registry/archive/refs/tags/0.1.0.tar.gz` and the `--registry` hint, because the tag is not on GitHub; `validate --registry <clone>` and `search` with `--registry` passed from the same directory; `--version` prints `0.1.0`; the cache directory stayed empty. No generated bytes, Showcase source, or website source changed, so the generators showed no drift and the Showcase and website builds were not repeated; captures were not run

Not tested, because they need the owner's publishing actions: a real snapshot download after the tag exists, the release workflow on GitHub, the Homebrew installation, and the notice against a real tap tag. The owner's steps are listed under Open deferrals

### Continuation checkpoint (2026-09-06)

The owner authorized continuing until Phases A through D are complete, and all four are. Phase A is local commit `4746b66`; the handoff documentation checkpoint is `7b2bca1`; Phase B is `41c2bd8`; Phase C is `3e5b53c` with its roadmap follow-up `f95ba7c`; Phase D is the implementation unit named above. Consult git for any work after this checkpoint. Nothing has been pushed. What remains is the owner's publishing sequence under Open deferrals; do not repeat or replace the passing implementations. Keep `OrderedJSON` for publishing and MCP insertion order, and `JSON.rendered` for sorted receipts and search

The Phase D requirements (resolution order, the cache and its clock, `--refresh` against `--force`, the notice, the release workflow, and the formula template) are met as recorded in the Phase D evidence; the publishing actions remain outside this session's authorization and are listed as owner steps

### Reproducible evidence and local logs

The verification commands and source map are in `HANDOFF.md`. Phase A also passed the full root `swift test`: five Foundations tests and 18 RegistryKit tests. The subprocess oracle is `Scripts/check_swift_parity.py`; build first, then let it discover the binary directory or pass `--binary /absolute/path/to/swiftui-registry`. It compares 1,184 command and response pairs after Phase B, not just parsed JSON

Supporting Phase A logs are `/tmp/swiftui-registry-stage6-final-build.log`, `final-tests.log`, `package-tests.log`, `final-parity.log`, `release-build.log`, `showcase-build.log`, and `format-check.log`, all with the same `/tmp/swiftui-registry-stage6-` prefix. These temporary files are not required to continue. The complete Showcase build log was `/Users/developer/Library/Developer/XcodeBuildMCP/workspaces/swiftui-cn-13dead7d9e93/logs/build_sim_2026-09-06T10-06-31-290Z_pid22783_a0f34d20.log`

The Showcase build generated an untracked workspace `xcshareddata/swiftpm/Package.resolved`; the session removed that generated file after verification. Do not commit an incidental workspace lockfile without reviewing whether the change requires it. No visual references or installed Showcase source changed during Phase A

Phase B logs are `/tmp/swiftui-registry-stage6-b-build.log`, `b-tests.log`, `b-python.log`, `b-full-parity.log`, `b-python-generators.log`, `b-swift-generators.log`, and `b-release.log`, each using the same `/tmp/swiftui-registry-stage6-` prefix. Reproduce the checks rather than depending on temporary logs

The subprocess oracle `Scripts/check_swift_parity.py` and the Python suites it compared against were deleted in Phase C; `41c2bd8` is the last commit that can rerun the 1,184-comparison proof. Phase C's Showcase UI run retained `/tmp/swiftui-registry-stage6-c-showcase-tests.xcresult`

### Handoff documentation verification (2026-09-06)

The documentation unit replaces the stale Stage 5 handoff with a restart procedure, source map, session authorization, commit trailers, and absolute verification commands. This roadmap records the continuation checkpoint and removal hazards; the migration contract records the command and disk compatibility checklist. The former Later-section deferral of MCP and release distribution was stale and is corrected to match the authorized Stage 6 scope

For this documentation unit, `swift build`, `swift test --filter RegistryKitTests` (18 tests), all 106 Python tests, both validators, all three generators with no output drift, `make format-check`, local Markdown link-target checks, and `git diff --check` passed. The subprocess oracle passed all 794 command pairs again, including complete file trees and bidirectional receipt updates. Logs are `/tmp/swiftui-registry-stage6-handoff-tests.log`, `handoff-python.log`, and `handoff-parity.log`, each using the same `/tmp/swiftui-registry-stage6-` prefix

No tool implementation, generated bytes, Showcase sources, or website sources changed in this unit. Release build, Showcase build and UI tests, captures, and website checks were not repeated for these documentation-only edits. Phase B through D remain implementation work, not completed by this documentation update

### Remaining phase gates

- Phase C: done 2026-09-06, evidence above
- Phase D: done 2026-09-06, evidence above, except the `brew install` documentation, which waits for the owner to create the tap repository (Open deferrals)

## Later

Complex data, presentation guidance, and messaging proceed only on evidence from named adopters. Native sheets, alerts, menus, navigation, scroll views, and split views are recipes by default, not installable wrappers. Finance and nutrition remain proof fixtures; illustrative domains do not count as adoption evidence

Deferred until real adoption proves the need: hosted registry services beyond the pinned release snapshots authorized in Stage 6, namespaces, authentication, federation, marketplace and multi-author workflows, automatic `.xcodeproj` mutation, macOS/watchOS/tvOS/visionOS claims, and a large typography/color/elevation token framework. The local MCP adapter and release snapshot distribution are part of the authorized Swift CLI rewrite, not deferred services

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
