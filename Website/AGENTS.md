<!-- BEGIN:nextjs-agent-rules -->
# Unfamiliar Next.js

APIs, conventions, file structure differ from training data. Read `node_modules/next/dist/docs/`; heed deprecations.
<!-- END:nextjs-agent-rules -->

# End-to-end tests

`npm run test:e2e:install` once (Chromium, WebKit). `npm run test:e2e` runs `e2e/` for both, builds `out/`, serves 127.0.0.1:4310, no server. Scope: `npx playwright test create.spec.ts --project=chromium`; last report: `npx playwright show-report`.
