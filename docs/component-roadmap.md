# Component roadmap

## Goal

Deliver valuable native SwiftUI product workflows as source-owned blocks, then extract only the reusable seams those workflows prove. The shadcn catalog is research input, not a build queue: stages are vertical product slices, not component-count parity, per the committed direction review (`GENERAL_DIRECTION_REVIEW.md`, "Roadmap changes")

A component does not replace a native control. `Button`, `TextField`, `Toggle`, `Picker`, `Menu`, `ProgressView`, `ScrollView`, `NavigationStack`, and system presentations remain visible at the call site. The registry standardizes them with SwiftUI style protocols, focused `ViewModifier`s, semantic theme values, and small compositions where one primitive is insufficient

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

The catalog holds 26 items: 17 installable components, 2 blocks, and 7 recipes. All 21 original Stage 1 rows are indexed: 14 are installable components, source-owned, installed into Showcase, and compiled at the iOS 18 platform floor; the remaining 7 rows (`aspect-ratio`, `direction`, `native-select`, `radio-group`, `tabs`, `switch`, `slider`) are recipes, native guidance carried in item `docs` with no installable files, per the item value gate in `docs/registry-spec.md`. The 3 block-driven components (`metric-card`, `transaction-row`, `macro-progress`) and the 2 proof blocks (`finance-overview`, `nutrition-overview`) complete the count. Launch Showcase with `-stage-one` to inspect the catalog

Stage 1 exit criteria were met: every foundation token is used by at least two completed registry items with the same semantic meaning; enabled, pressed, focused, selected, disabled, and invalid states are demonstrated where applicable; the showcase proves light, dark, RTL, and accessibility text sizes. Runtime and compile evidence is recorded in `STAGE_ONE_VALIDATION.md`

## Stage 1.5: Adoption contract

**Status: Delivered except the clean-room trial**

This stage makes one external install/customize/update workflow excellent before adding breadth. What is in place:

- Item taxonomy and value gate: the `recipe` kind separates native guidance from installable source, and an installable item must add a meaningful reusable treatment or composition (`docs/registry-spec.md`, "Item value gate")
- Unified validation: `Scripts/registry_validation.py` is the single structural validator used by install, search, `Scripts/validate.py`, catalog generation, and CI tests
- Inspectable install: `Scripts/install.py --plan` prints the ordered closure, per-target statuses, package requirements, collisions, and manual integration steps without writing; `--diff` audits owned source against canonical registry source
- Actionable package metadata: every version requirement carries a `sourceURL` and a machine-resolvable `swiftPM` rule, with the compatibility policy in `docs/registry-spec.md`
- Generated per-item documentation: `docs/catalog/` is generated from metadata by `Scripts/generate_catalog.py`, each page leading with preview, install command, and a `usage` snippet, with recipes leading with the snippet because nothing installs; a freshness test keeps it byte-identical to the metadata
- Clean-room trial: **open**. An independent developer or coding agent must discover, inspect, install, compile, customize, and update one block in an app outside `Examples/Showcase`, with time, manual steps, and failure points recorded. This is the missing go-to-product evidence and the remaining gate before Stage 2

## Stage 2: Two block-led workflows

Build two complete product workflows as dependency-closed blocks, then extract shared treatments only from proven repetition

1. **Authentication form**: sign-in and sign-up surfaces exercising validation, focus order, secure input, autofill, and error feedback
2. **Settings section**: grouped preferences exercising switches, selection, separators, and destructive actions

Extract `field`, `input-group`, or form treatments only when the two slices prove the same seam. Do not pre-build a forms catalog

### Stage 2 exit criteria

- Both blocks install, compile, and render from their resolved closures at the iOS 18 floor
- Focus order, keyboard behavior, validation announcements, autofill, and disabled states are verified at the UI
- Every composition accepts bindings and actions without owning validation, upload, or persistence logic
- Any extracted shared treatment names its two proving usages

## Stage 3: Content and feedback driven by one real screen

Choose one coherent real screen and add only the empty, loading, inline-alert, and row treatments it actually requires. Candidates from the research appendix (accordion, avatar, skeleton, kbd, and the rest) stay unbuilt until that screen names them

### Stage 3 exit criteria

- Feedback is distinguishable without color alone
- Decorative imagery is hidden from accessibility and meaningful media has caller-provided labels
- Placeholder states do not trigger product actions or effects

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
