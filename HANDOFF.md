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
| Showcase | `Examples/Showcase/`, demos in `ItemDemos.swift`, `ComponentDemos.swift`, `BlockDemos.swift`, `RecipeDemos.swift`; the UI suite and its visual references; iPad captures through `Scripts/capture_previews.py --blocks` on the iPad Pro 13-inch (M5) whose UDID is `IPAD_UDID` in that script |
| Captures | `Scripts/capture_previews.py` on the pinned iPhone 17 and the iPad Pro 13-inch, then the three generators |
| Website | `Website/` (Next.js 16, shadcn/ui base-nova; read `Website/AGENTS.md` first); the preset codec `Website/lib/preset.ts`; the Create page `Website/components/create-studio.tsx`; search `Website/components/search-command.tsx` and `Website/lib/search.ts` |
| Example consumer | `Examples/TodoCounter/` with its three UI layers and the comparison |
| Point-Free skill format | `~/.claude/skills/pfw-*/SKILL.md` (frontmatter, Goal, Quick start, API interface, How-to sections with templates and DO / DO NOT bullets, `references/interface/*.swiftinterface`), and `pfw-pfw/SKILL.md` for how the family is meant to be used |
| Design and DX research | knowledge hub topics `design-polish-and-accessibility`, `developer-workflow-and-tooling`, `ai-assisted-development`, `view-composition-and-swiftui-patterns`; the Point-Free vault arcs named above; Apple's Human Interface Guidelines and the `apple-liquid-glass`, `swiftui-specialist`, and `swiftui-whats-new-27` skills for iOS 26 and 27 facts |

## Morning report

Written by the loop when it stops. Lead with what shipped, then what is blocked and why, then the two or three things the owner should look at first
