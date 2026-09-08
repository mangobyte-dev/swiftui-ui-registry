# Release checklist

The contract for a public beta of this repository, written 2026-09-08 from how shadcn-ui/ui and the pointfreeco packages present a release, then made concrete for this repo. A line closes only with evidence: a command's output, a file path with a line, or a test log with executed counts. A line that cannot close says why

What the reference repositories do, read on 2026-09-08 from the GitHub API listing of each repository root and its releases:

- shadcn-ui/ui keeps `README.md`, `CONTRIBUTING.md`, `LICENSE.md`, `SECURITY.md`, `RELEASING.md`, and `.github/` with issue templates, Dependabot, and workflows at the root; release notes are changesets grouped as Minor Changes and Patch Changes with one line per change and its pull request. `CONTRIBUTING.md` opens with the repository layout as a table
- pointfreeco/swift-dependencies, swift-sharing, and swift-composable-architecture keep `README.md`, `LICENSE`, `Makefile`, `Package.swift`, `.spi.yml`, `.editorconfig`, `Sources/`, `Tests/`, `Examples/` (sharing, TCA), and `.github/` with `CODE_OF_CONDUCT.md`, `ISSUE_TEMPLATE/`, and `workflows/`; no `CHANGELOG` file, the release notes live on the tag as What's Changed with Added, Fixed, and Infrastructure bullets and a Full Changelog compare link; tags are bare semantic versions with no `v` prefix. Their README runs intro, Learn More, Overview, Quick start, Examples, Documentation, Installation, Community, License

This repository already tags bare versions (`0.1.0`, `0.2.0`), keeps its release notes on the GitHub release, and builds the universal binary from `.github/workflows/release.yml`. The beta adds a `CHANGELOG.md` at the root so the notes exist before the tag and survive outside GitHub

## 1. Repository shape

- [ ] 1.1 The root holds only what an adopter needs: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `AGENTS.md`, `CLAUDE.md`, `Package.swift`, `Package.resolved`, `Makefile`, the dot files, `Distribution/`, `Examples/`, `Registry/`, `Scripts/`, `Skills/`, `Sources/`, `Tests/`, `Website/`, `docs/`
- [ ] 1.2 Planning, research, run logs, and notes to self are moved out of git into `~/Projects/swiftui-cn-local/` with a one-line index there, each judged by reading it: `HANDOFF.md`, `PRODUCT.md`, `GENERAL_DIRECTION_REVIEW.md`, `STAGE_ONE_VALIDATION.md`, `docs/component-roadmap.md`, `docs/research.md`, `docs/research-stage-7.md`, `docs/clean-room-trial.md`, `docs/cli-migration.md`, `tasks/`, and the untracked `tmp/` and `swarmforge/`. `docs/mango.md` stays as the design-system template if its research citations can be rewritten as plain statements
- [ ] 1.3 Every link, README section, skill, test, and generator that pointed at a moved file is updated; `git grep` for each moved name returns nothing outside `docs/catalog/` and `Website/content/`
- [ ] 1.4 `AGENTS.md` describes the shipped repository: its document map names only files that exist, state lives in `CHANGELOG.md` (shipped and known limitations) rather than a roadmap, and the verification list runs as written
- [ ] 1.5 Every kept markdown file is read in full and corrected: stale counts, dead paths, wrong commands, plans described as behavior. No em dashes in prose anywhere in the tree (`git grep -n "—" -- '*.md' '*.swift' '*.ts' '*.tsx'` is empty outside quoted third-party text)
- [ ] 1.6 `CONTRIBUTING.md` opens with the repository layout and the verification list, as the reference repositories do; `SECURITY.md` names the supported versions by tag; `CODE_OF_CONDUCT.md` stands
- [ ] 1.7 `.github/` keeps the issue templates, the pull request template, Dependabot, CODEOWNERS, and the three workflows, and each workflow's steps still match the repository after the moves

## 2. The Stage 9 surface, polished

Driven on the iOS 27 simulators (iPhone 17 and iPad Pro 13-inch) in the Showcase and in both host apps. Every defect gets a failing test first where a test can hold it, then the fix; the tool's chrome stays fixed (system values, never the tuned theme)

- [ ] 2.1 Open, select, tune: the Tune button opens the card, Select picks the innermost item, a knob moves the item live, the card's chrome does not move
- [ ] 2.2 Drag the card off every edge and back: leading, trailing, bottom, top; the grab strip stays reachable; the card never leaves the safe area past its strip
- [ ] 2.3 Resize to the minimum and the maximum; the content stays usable at the minimum and the grip stays reachable at the maximum
- [ ] 2.4 Rotate with the card up; the frame is clamped into the new area and remembered per size class
- [ ] 2.5 Collapse and reopen; the frame and the selection survive
- [ ] 2.6 A sheet and a full-screen cover under the panel: items inside them select, the card stays above, the sheet's own touches work
- [ ] 2.7 The keyboard in a panel text field: the card keeps its place, the field is reachable, the keyboard dismisses cleanly
- [ ] 2.8 Select on nested items: the chain lists every item under the pick, innermost first; a pick with nothing under it clears the selection without a crash and leaves Select disarmed
- [ ] 2.9 Reduce Motion: no animated card movement or selection ring animation beyond what the setting allows
- [ ] 2.10 Dynamic Type at accessibility sizes: the panel's rows, the drag bar, and the grip stay usable; the minimum size grows with the text
- [ ] 2.11 Dark and light: the card, the ring, the outlines, and the guides read on both
- [ ] 2.12 Right to left: the card's default place, the snap edge, the grab strip, and the outlines mirror correctly
- [ ] 2.13 VoiceOver: every control in the window has a label; the Tune button, the drag bar, the collapse, the grip, the Select capture, the On this screen rows
- [ ] 2.14 A host with no page for a picked item: the panel stays on its form, no push, no empty page
- [ ] 2.15 A host document that fails to decode: the store falls back to the shipped document, logs once, and never crashes; the file is not clobbered until a change is made
- [ ] 2.16 A remembered card frame after a size-class change: the compact and regular frames are separate and each is clamped when restored
- [ ] 2.17 Memory when the panel opens and closes 50 times: no growth beyond the first open (measured with the simulator's memory report or an XCTest metric)
- [ ] 2.18 The Showcase UI suite passes on the iPhone 17 pin with executed counts read from the log; the two stale references are the only known failures or are recaptured with a GOLDEN-CHANGE note by the owner
- [ ] 2.19 seeFood's Design mode runs on the registry product with no app-side workaround; any one-line adoption edit is noted
- [ ] 2.20 kutayib builds against the registry and its installed items render; any one-line adoption edit is noted

## 3. Edge cases at the product boundary

Every public symbol in `SwiftUIRegistryFoundations` and `SwiftUIRegistryDesignSurface` read, asking what a host can pass that breaks it

- [ ] 3.1 `ItemSelection.chain` and `pick` with an empty frame list, duplicate names, zero-area frames, and a point outside every frame
- [ ] 3.2 `designSurface` applied twice in one tree, or with `knobs` registered twice for one item: the later registration wins or is rejected, never a crash
- [ ] 3.3 `itemTitle` returning an empty string: the row and the ring fall back to the name
- [ ] 3.4 `page` returning a view for an item that is not on screen, and a page closure that is expensive: called once per pick, never per frame
- [ ] 3.5 `registryScreen` names that nest, repeat, or are empty; `registryItem` with an empty name
- [ ] 3.6 A token file written by a newer version, an empty file, or a file with unknown keys: decode falls back and is logged, the shipped document applies
- [ ] 3.7 `ItemKnob` with an inverted range, a zero step, or a shipped value outside the range: clamped or rejected at registration with a clear message
- [ ] 3.8 `TokenDocument.pages` empty, a page with no knobs, a choice knob whose current value is not among its options
- [ ] 3.9 Package tests hold each boundary case that can be held without UIKit; Showcase package tests hold the rest

## 4. The tool and the installer

- [ ] 4.1 `search`, `describe`, `info`, `install --plan`, `install`, `install --diff`, `install --update`, and `preset` run against a scratch package with expected output
- [ ] 4.2 The same against seeFood's and kutayib's package trees: receipts round-trip through `info`, `--diff` reports the owned edits, `--update` without `--force` never overwrites a customized owned item
- [ ] 4.3 The skills' `.swiftinterface` references are regenerated from the built products and match the public API
- [ ] 4.4 The root package tests pass with the executed count read from the log
- [ ] 4.5 The Showcase package tests pass with the executed count read from the log
- [ ] 4.6 The Showcase UI suite passes on the iPhone 17 pin with the executed count read from the log (see 2.18)
- [ ] 4.7 The generated outputs are byte-identical after the four generators (`git diff --exit-code` on the generated paths)
- [ ] 4.8 `make format-check` passes
- [ ] 4.9 The website typechecks and builds

## 5. Release artifacts

- [ ] 5.1 `CHANGELOG.md` at the root with the beta entry in adopter language: the design surface as a window over a host app, `TokenDocument`, per-item knobs, the host hooks, `ItemSelection.chain`, fixed tool chrome, the off-edge card, and the known limitations
- [ ] 5.2 `README.md` reflects the current API and opens with a five-minute quickstart that works when followed literally
- [ ] 5.3 The version constant in `Sources/RegistryKit/ReleaseSnapshot.swift`, the Homebrew formula template, every installable item's foundations floor, and the requirement the installer prints agree on the beta version
- [ ] 5.4 The tag and push commands are prepared in the morning report; nothing is pushed or tagged tonight
- [ ] 5.5 Each commit tonight has a subject, a body saying what changed and why, and one `By <role>.` line, nothing else

## Beta version

`0.3.0`. Foundations gained public API after `0.2.0` (`registryItem`, `registryScreen`, `registryKnob`, the reporter) and the design surface became a second product; under 1.0 that is a minor bump, and every installable item applies `registryItem`, so the item floor is the tag itself
