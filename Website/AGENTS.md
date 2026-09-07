<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

# End-to-end tests

Run `npm run test:e2e:install` once to fetch the Chromium and WebKit browsers, then `npm run test:e2e` runs the Playwright suite in `e2e/` across both projects (the config builds `out/` and serves it on 127.0.0.1:4310, so no server needs starting).
Scope a run with `npx playwright test create.spec.ts --project=chromium`, and open the last HTML report with `npx playwright show-report`.
