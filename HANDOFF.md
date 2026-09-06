# Handoff: after Stage 5, the theme preview wall

Written 2026-09-06 at the end of the Stage 5 run. State lives in `docs/component-roadmap.md` (Current state, Open deferrals, the Stage 5 section with its exit-criteria evidence, and the Backlog); this file is the brief, not a second home for state

---

I am Mo, the owner of SwiftUIRegistry. Stage 5 recreated everything shadcn's `/create` page previews: the five primitives it lacked (`field`, `chart`, `table`, `combobox`, `breadcrumb`) and the two walls, `preview` (33 cards) and `preview-02` (35 cards), each an installable block whose cards compose registry items and native controls with neutral sample data. The six theme captures and the website's Create and Themes pages now show the wall's first screen per preset. The placement rule for presentation choices (a `registry`-prefixed trailing call, never an initializer parameter) is in `AGENTS.md`. Everything is pushed and the site is deployed. Read `AGENTS.md`, then the Stage 5 section of the roadmap

## What is waiting for me

1. Replace the two visual references, reviewed first, then re-run the suite. `auth-light` (2.67 percent, stale since the audit) and `nutrition-light` (1.53 percent) fail only because their blocks reach the accent strip above the tab bar; the other 17 UI tests and the 7 Showcase unit tests pass on every run. The reviewed candidates are exported next to this session's final result bundle at `/private/tmp/claude-501/-Users-developer-Projects-swiftui-cn/7db8cc48-cfcb-4ea2-8c09-ebfba8bf4c18/scratchpad/final5-attachments` (`auth-light.png`, `nutrition-light.png`); the copy commands are under "Reference replacement" below
2. Decide the GitHub Pages workflow: `.github/workflows/pages.yml` fails at its deploy step on every push because Pages is not enabled for the repository; enable Pages with the GitHub Actions source, or delete the workflow since Cloudflare Workers is the deploy path
3. The owner decisions from the audit still stand in the roadmap's "Deferred, with the reason"
4. Next stage, when I say go: the Swift CLI, recorded in Backlog item 11 as a rewrite of the whole Python path (installer, validator, receipts and merge, search, presets, MCP) with command parity and the same receipts on disk as the exit criteria; nothing has started
5. argent 0.24.0 is available and was not installed

## Reference replacement

After reviewing each candidate (they are the real screens with the strip above the three-tab bar):

```sh
OUT=/private/tmp/claude-501/-Users-developer-Projects-swiftui-cn/7db8cc48-cfcb-4ea2-8c09-ebfba8bf4c18/scratchpad/final5-attachments
cd Examples/Showcase/SwiftUIRegistryShowcaseUITests/ReferenceImages
for name in auth nutrition; do
  cp "$OUT/$name-light.png" "$name-light.png"
done
```

`docs/visual-testing.md` carries the GOLDEN-CHANGE note dated 2026-09-05 for this replacement

## Facts measured this run

- The iPad Pro 13-inch simulator used for the wide captures was set to ar_SA, which put Hijri dates and spaced currency into the first wall captures; every capture now launches with `-AppleLanguages (en) -AppleLocale en_US` and the iPad is set to en_US for its status bar date (pins in `AGENTS.md`)
- XcodeBuildMCP keeps a session profile; a worker running `test_sim` while the `ipad-qa` profile was active reported 13 false tab-bar failures. Check the active profile before any simulator test, or run `xcodebuild` with an explicit destination
- The full UI suite now takes about 27 minutes on the pinned iPhone because the demo walk audits both non-lazy walls (68 cards); run subsets with `-only-testing` for slice gates and the full suite once per push
- `inspector(isPresented:)` on a tab's navigation stack stops the auth form's Return key from moving focus on iOS 27 even while nothing is presented; the iPad column is a plain `HStack` sibling
- The item capture route is one screen tall, so a wall's capture shows its first screen; the audit covers every card because the compact wall is a non-lazy `VStack`
- argent's `describe` returns an empty tree for this app on the pinned iPhone and its taps do not land on the iPad; XcodeBuildMCP's `snapshot_ui` and `tap` work on the iPhone, and the UI suite is the proof
- A local commit-msg hook (swarmforge) appends "By specifier." to every commit message; it is harmless and outside the repository

## Rules that still bind

Everything in `AGENTS.md`; no em dashes; do not push, tag, or deploy without the owner (the owner authorized push and deploy for this run on 2026-09-06); never write into `ReferenceImages/` from an agent session; no large agent fan-outs, one Opus 4.8 worker per slice
