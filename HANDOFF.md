# Handoff: after the SwiftUI best-practice audit

Written 2026-09-05 at the end of the audit session. State lives in `docs/component-roadmap.md` (Current state, Open deferrals, and the Audit section); this file is the brief, not a second home for state

---

I am Mo, the owner of SwiftUIRegistry. The audit of every registry item, the foundations, and the Showcase harness against SwiftUI best practice is done and committed locally in 18 commits (`390db1c` through `938da68`); nothing is pushed. Read `AGENTS.md`, then the Audit section of `docs/component-roadmap.md`

## What is waiting for me

1. Replace the three stale visual references (`auth-light.png`, `activity-light.png`, `nutrition-light.png`) from the audit run's reviewed attachments and add the GOLDEN-CHANGE note; the Audit section names the result bundle. Until then `testAuthValidationSurfacesFieldAndFormErrorCopy` fails at 1.95 percent against the 1.5 percent tolerance and the other 17 UI tests pass
2. Decide the owner items in "Deferred, with the reason": the `button-group` item that renders as the stock capsule, the checkbox double dim, the bare dividers and the native button in the two Stage 1 blocks, the wash opacities, the preview guard convention, preview strings in consumer catalogs, and the bundle policy for package installs
3. argent works again on the Xcode 27 beta simulators after two fixes on 2026-09-05: the SimulatorKit symlink under `Contents/Developer/Library/PrivateFrameworks/` (relative, wiped by every beta update) and a native, detached tool-server (`arch -arm64 argent server start --detach`; the previous one ran under Rosetta and its child could not load the arm64e-only framework). 0.24.0 is available and was not installed

## Rules that still bind

Everything in `AGENTS.md`; no em dashes; do not push, tag, or deploy without the owner
