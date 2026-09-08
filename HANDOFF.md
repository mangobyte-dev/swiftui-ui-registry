# Handoff: the overnight Stage 7 run

This is the brief for one long autonomous session that takes the registry further. The owner starts it from the repository root with:

```text
/loop Read HANDOFF.md and run the next Stage 7 slice end to end as it describes. Keep looping until Stage 7's exit criteria in docs/component-roadmap.md are met, then stop.
```

Why a loop and not one goal-shaped turn: the goal is the work list and the exit criteria in the roadmap, and the loop is only the mechanism that survives the night. One turn can run for hours, but a long session occasionally ends a turn early with a statement of intent instead of a tool call; a self-paced loop re-enters the same brief at once, and every tick starts by reading the roadmap's Stage 7 status, so nothing is lost and nothing is repeated. Each tick delivers one slice completely and schedules the next tick with the shortest delay while slices remain; when the exit criteria are met, the loop stops itself and pushes a notification. If the harness ever shows a context countdown, ignore it: you have ample context, do not stop, summarize, or suggest a new session on account of context limits

## Read first, in this order

[AGENTS.md](AGENTS.md), [philosophy](docs/philosophy.md), [architecture](docs/architecture.md), the [registry specification](docs/registry-spec.md), then [the roadmap's Stage 7](docs/component-roadmap.md#stage-7-shadcn-parity-ipad-the-mango-theme-the-create-studio-developer-experience-and-skills) for the work list, the slice order, the status of each slice, and the exit criteria. The roadmap is the only home for status and plans; this file only says how to run

Then read the memory directory the harness loads for this project (the `MEMORY.md` index and the files it points to). The rules there are binding: no assistant co-author or session trailers in any commit message, no large subagent fan-outs, no `cd` in concurrent shell commands

## What a tick does

1. Read Stage 7 in the roadmap and take the first slice that is `open` and not blocked. Mark it `in progress` with the date before touching code
2. Research before design when the slice says so. The knowledge hub is consulted before the web (`~/.claude/skills/knowledge-hub/SKILL.md`; topics live in the Obsidian vault it names, and the Point-Free vault beside it holds the arcs `workflow-project-structure.md`, `dependency-injection.md`, and `skill-arc-synergy.md`). Record findings in `docs/research-stage-7.md` as a dated record with citations: an episode number, a document URL, a file path with a line, or a command's output. A claim without one is marked `[unverified]`
3. Build the slice as the registry's own rules require: raw SwiftUI controls visible at the call site, presentation in style protocols and `registry` modifiers, tokens from foundations only when two items need them, the value gate for recipes, every item with metadata, usage, accessibility notes, previews, captures, and a Showcase demo. The website reads only generated data
4. Verify with the scoped verification list in AGENTS.md before every commit, and run the Showcase UI suite after any visible change. Before reporting progress, audit each claim against a tool result from this session; report only work you can point to evidence for, and name anything skipped in the same sentence as the done-claim
5. Commit with a message that describes the change and nothing else (the local hook appends its own line). Push to `main` when the verification list and the Showcase suite are green; deploy the website with `npm run deploy` in `Website/` after a website slice. Never rewrite history, never replace a visual reference, never move or delete the `0.1.0` tag, never change the preset code format without a new version letter
6. Record: the slice's status and evidence in the roadmap, one lesson per file in the memory directory when something non-obvious was learned (update an existing note rather than duplicating; delete notes that turn out wrong), and the next slice
7. Schedule the next tick with the shortest delay while slices remain. Stop the loop only when every slice is `done` or `blocked` with its blocker recorded; then write the morning report at the end of this file and send a one-line notification

## Orchestration

You are the orchestrator. Delegate independent, slice-sized work to `opus48-worker` subagents (Claude Opus 4.8, the owner's rule for workers) and keep working while they run; at most three run at once, and a slice never fans out into more than a handful of agents. Each worker gets the slice's goal, the files it may touch, the AGENTS.md rules that apply, the verification commands, and the instruction to commit nothing. You review every diff, run the verification yourself, and commit. Before each commit, give a fresh-context verifier subagent the diff and the slice's acceptance criteria with the instruction to refute the claim that the slice is done; fix what survives. Intervene when a worker drifts from a rule or lacks context

Pause for the owner only when the work genuinely requires them: an irreversible action outside this brief's scope, a real scope change, or input only they can provide. Record such a pause in the roadmap as the slice's blocker and move to the next slice; do not end the loop on it

## Boundaries

Stay inside the seven workstreams of Stage 7. Do not add dependencies without a slice that proves the need, do not refactor what a slice does not touch, and do not create documents outside the four classes AGENTS.md names. Release `0.2.0` only as the last slice, only when every other slice is done and CI is green, and only by the documented path: bump the tool's version constant, tag, publish the GitHub release, update the tap formula's checksum and tag. If anything about that slice is uncertain, leave it for the owner

## Where things are

| Concern | Place |
|---|---|
| Registry items and sources | `Registry/items/*.json`, `Registry/sources/components/`, `Registry/sources/blocks/`, the schema and the preset vectors under `Registry/` |
| The tool | `Sources/RegistryKit/` (validator, installer, search, presets, MCP, generators, snapshot cache), `Sources/SwiftUIRegistryCLI/`; tests and captured fixtures in `Tests/RegistryKitTests/` |
| Showcase | `Examples/Showcase/`, demos in `ItemDemos.swift`, `ComponentDemos.swift`, `BlockDemos.swift`, `RecipeDemos.swift`; the UI suite and its visual references; iPad captures through `Scripts/capture_previews.py --ipad` (every item, or the named ones; `--blocks` limits it to blocks) on the iPad Pro 13-inch (M5) whose UDID is `IPAD_UDID` in that script |
| Captures | `Scripts/capture_previews.py` on the pinned iPhone 17 and the iPad Pro 13-inch, then the three generators; `--themes [names]` for the preset walls, `--scene <route>` for a Showcase scene that is not an item (the MANGO demo is `mango-demo`) |
| Website | `Website/` (Next.js 16, shadcn/ui base-nova; read `Website/AGENTS.md` first); the preset codec `Website/lib/preset.ts`; the Create page `Website/components/create-studio.tsx`; search `Website/components/search-command.tsx` and `Website/lib/search.ts` |
| Example consumer | `Examples/TodoCounter/` with its three UI layers and the comparison |
| Point-Free skill format | `~/.claude/skills/pfw-*/SKILL.md` (frontmatter, Goal, Quick start, API interface, How-to sections with templates and DO / DO NOT bullets, `references/interface/*.swiftinterface`), and `pfw-pfw/SKILL.md` for how the family is meant to be used |
| Design and DX research | knowledge hub topics `design-polish-and-accessibility`, `developer-workflow-and-tooling`, `ai-assisted-development`, `view-composition-and-swiftui-patterns`; the Point-Free vault arcs named above; Apple's Human Interface Guidelines and the `apple-liquid-glass`, `swiftui-specialist`, and `swiftui-whats-new-27` skills for iOS 26 and 27 facts |

## Morning report

Written by the loop when it stops. Lead with what shipped, then what is blocked and why, then the two or three things the owner should look at first

### 2026-09-07, the Stage 7 run

Ran from 21:31 on 2026-09-06 to 11:10 on 2026-09-07 as one `/loop` session (one restart at about 06:20 wiped the temporary folder and cost a suite rerun). Every slice is `done`; `0.2.0` is published: tag, GitHub release with the universal binary, the tap at 0.2.0, `brew upgrade` verified, the live snapshot fetched.

| Slice | Commit | What shipped |
|---|---|---|
| 1 Research record | 57f7c90 | `docs/research-stage-7.md`: 43 sourced findings, decisions D1 to D8, the pain-point section |
| 2 Inventory | daccc4b | 134 shadcn rows dispositioned in the roadmap matrix |
| 3 Parity, part one | 64f206d | 6 components (attachment, bubble, marker, message, message-scroller, toast), 7 recipes, catalog 70 |
| 4 Parity, part two | e2ab086 | 3 blocks (dashboard, signup-form, questionnaire), `describe` and `info` commands, catalog 73 |
| 5 iPad | bd9881c, fb88f2c | 146 iPad captures on every item page, pointer effect restored on button, checkbox, accordion, breadcrumb, the sidebar recipe with `sidebarAdaptable`, the UI suite on the iPad destination |
| 6 MANGO | 9358c8e | `.mango` preset, code `a74hGF01CVunaG0vzZJG`, a Showcase demo with two owned copies, Themes and Create entries, `docs/mango.md` |
| 7 Create studio | 324cfe6 (with slice 8) | preset format `b`: font design, elevation ladder, chart palette, background and foreground pairs; the studio, the tuning panel, and the three codecs updated together; 7 new vectors, every `a` code unchanged |
| 8 Website e2e | 324cfe6 | Playwright in Chromium and WebKit iPhone: 35 passed, 1 skipped, console clean, both 2026-09-06 crashes as regression tests, a CI `e2e` job |
| 9 Skills | d9116da | `Skills/swiftui-registry`, `-theming`, `-authoring`, mirrored to `~/.claude/skills/` |
| 10 Release 0.2.0 | bc5e852, tag at 676e41c | version constant, chart floor 0.2.0, formula, tests; release `0.2.0` with the binary and its sha256, tap tag `swiftui-registry-0.2.0`, brew upgrade 0.1.0 to 0.2.0, website redeployed |

| Verification at the end | Result |
|---|---|
| `swift test` | 70 RegistryKit and 8 foundations tests pass |
| Showcase package tests | 16 pass on the iPhone simulator |
| UI suite, iPhone 17 | 20 tests, 1 skipped (the iPad-only pointer test), 2 failures: the stale `auth-light` and `nutrition-light` references you own |
| UI suite, iPad Pro 13-inch | 20 tests, 0 failures, 1 measured skip (Return-key focus, simulator state), no idle timeout with animations off |
| Playwright | 35 passed, 1 skipped (the WebKit-only replaceState test on Chromium) |
| Website | typecheck, lint, build, deployed at https://swiftui-registry.mangobytekw.workers.dev |
| CI | green on 676e41c (registry gate, website, end-to-end, secret scan); the first e2e run failed on runner speed and was fixed in 676e41c |

| Blocked or deferred | Why | Where recorded |
|---|---|---|
| Two stale visual references | `auth-light` 2.69 percent and `nutrition-light` 1.53 percent; replacing a reference is your call | Open deferrals |
| iPad simulator idle stall | the iOS 27.0 iPad simulator stops reporting animations idle after keyboard input; investigated (not the pointer, not hoverEffect, not the keyboard language); the suite passes `-disable-animations` on the iPad and the stalls are gone | Open deferrals, fb88f2c |
| iPad Return-key focus | after a few launches the simulator dismisses the keyboard on Return; the same committed build passes first after a boot; the test reports it as a measured skip on iPad only, the iPhone asserts it | Open deferrals, 324cfe6 |
| `warning` semantic | not added: no two items adopted it in slice 7 (D4) | slice 7 evidence |
| Slices 7 and 8 share one commit | a staging error merged them under the slice 8 subject; history is not rewritten | slice 7 evidence |

Look at these first:

1. The Create studio on your phone: https://swiftui-registry.mangobytekw.workers.dev/create/?preset=b3spZukjxUN1w5qQy4eQI (MANGO with rounded type and the spectrum chart, a `b` code) and the Themes page's MANGO section.
2. `docs/mango.md`, the template a team follows, and `Skills/` (the three skills are live in `~/.claude/skills/`).
3. The two stale references under Open deferrals: decide whether to replace them (GOLDEN-CHANGE) or fix the blocks.

## The Stage 8 run (2026-09-08)

Started by the owner as `/loop keep working till you finish everything. keep track of yourself in a md file, not your context.` This section is that file: the loop's own log, one line per tick, newest last. The plan, decisions, and slice status stay in the roadmap's Stage 8 section; this log only says what the loop did and where it stopped

Standing notes for this run: commits are left to the owner (the harness in this session appends assistant trailers the owner forbids), so each slice ends with a verified working tree and a roadmap entry, not a commit; argent's taps do not land on the pinned iPhone 17 this morning, XcodeBuildMCP's `snapshot_ui` and `tap` do

| Tick | Did | Next |
|---|---|---|
| 1 (10:30) | Slice 1 verified and recorded (see the roadmap). Read the spec's evolution and ownership rules, the item metadata shape, and the token references across every source for slice 2's design | Foundations hook (`registryItem(_:)`, anchor preference, surface environment), the tagging of every installable item by three workers, the item-tokens generator, the surface's selection mode and scoped panel |
| 2 (11:15) | Foundations hook `registryItem(_:)` with the anchor preference and the surface environment (`Sources/SwiftUIRegistryFoundations/RegistryItem.swift`); three workers tagged all 48 installable item roots (reviewed: one tag per root, names match, five files restructured around `Group`); 48 items bumped one patch with the foundations floor `0.2.1`; every item reinstalled into the Showcase with `--force`; the fourth generator `generate item-tokens` writes `RegistryItemTokens.swift` (48 entries) and the drift test covers it; the surface gained Select mode (one capture layer over the content, innermost frame wins) and the panel a scope section that filters Surface, Chart, Density, Radius, Spacing, and State by the selected item's tokens; contract tests repinned to the new versions | Showcase build and suites, a UI test for Select, the persistence and release checks again, roadmap slice 2 evidence |
| 3 (11:50) | Slice 2 built end to end: nonisolated fix for the tag, the validator's root-tag rule with fixtures, the theming skill how-to and the regenerated interface, the Select UI test passing, Release build proof | Full iPhone suite in the background; then the persistence recheck, slice 2 done in the roadmap, slice 3 (spec and architecture text, the optional simulator path helper decision), and the closing report |
| 4 (12:25) | Full iPhone suite: 40 passed, 1 skipped, the 2 stale references at the same percentages as before the tag; slices 2 and 3 recorded `done`; Stage 8 `done` with the `0.2.1` release named as the owner's step in Open deferrals | Nothing; the loop stops. Owner: review the tree, commit, release foundations `0.2.1`, replace the two stale references |

