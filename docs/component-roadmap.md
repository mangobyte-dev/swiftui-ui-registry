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
- Showcase is a browsable catalog (Components, Blocks, Recipes, Tune) with a generated manifest, a demo per item, a capture launch route, and the theme tuning panel with Swift export
- The website is a Next.js static site built with shadcn/ui under `Website/`, fed by generated `content/registry.json`, with a page per item and a Themes page, deployed 2026-09-05 to Cloudflare Workers at https://swiftui-registry.mangobytekw.workers.dev; `docs/images/items/` and `docs/images/themes/` hold the light and dark captures
- Stage 4 (2026-09-05): the command and search screen, `command-search`, named `input-group`, `kbd`, and `command`; status and evidence in its section below
- First consumer outside `Examples/Showcase`: the seeFood app installed settings-section, select, separator, button, and input on 2026-09-01 through a local path dependency, with the receipt in its destination; the published URL remains unexercised because no tag exists
- Current catalog counts and per-item pages live in the generated `docs/catalog/index.md` and the website, not in prose here

### Open deferrals

Standing debt already on record. A done-claim that touches one of these areas names it

- iOS 26 runtime evidence: no iOS 26 simulator runtime is installed, so the floor is verified by compilation and the iOS 27 runtime only
- The `0.1.0` tag exists locally (2026-09-05) and is not pushed, so the published URL still resolves nothing until the owner pushes it (`docs/registry-spec.md`). The site has no custom domain yet; `.github/workflows/pages.yml` remains as an alternative deploy path
- Visual threshold coarseness: the 2 percent tolerance at 96 by 192 absorbed a whole tab-bar change once (`docs/visual-testing.md`, GOLDEN-CHANGE 2026-09-01)
- seeFood's theme bridge compiles unchanged against the 2026-09-05 foundations (every new initializer argument has a default) but does not yet set `accent` or `onAccent`; adopting them is that app's decision
- Reduce Motion, VoiceOver announcement timing, and the accordion's rotation are verified structurally and on the simulator, not on a device

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
