import { defineConfig, devices } from "@playwright/test"

// The site is a static export (next.config.ts: output "export", trailingSlash,
// out/). Playwright builds it and serves out/ with Python's stdlib http server,
// so the suite needs no server dependency of its own. Two projects: Desktop
// Chrome, and an iPhone WebKit profile for the history.replaceState regression.
const PORT = 4310
const baseURL = `http://127.0.0.1:${PORT}`

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  // Two iOS simulators run the Showcase UI suites on the dev machine; two
  // workers keep this suite off their CPU. CI sets its own budget the same way.
  workers: 2,
  retries: 0,
  reporter: process.env.CI ? [["github"], ["html", { open: "never" }]] : "html",
  // The expect timeout is short per the brief; the per-test budget is larger
  // only so a slow first hydration (the machine also runs two iOS suites) does
  // not cap a test whose individual assertions each settle in well under 5s.
  timeout: 60_000,
  expect: { timeout: 5_000 },
  use: {
    baseURL,
    trace: "on-first-retry",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
    {
      name: "webkit-iphone",
      use: { ...devices["iPhone 15"] },
    },
  ],
  webServer: {
    // Serve the static export with Python's stdlib http.server (no new
    // dependency). `python3 -m http.server` fixes the listen backlog at 5, and
    // two parallel workers overflow it under load: connections reset, a dropped
    // JS chunk is not retried, and the page fails to hydrate. This is the same
    // ThreadingHTTPServer module with the accept backlog raised, nothing more.
    // CI builds the export in its own step before the tests, so only a local
    // run builds here.
    command: `${process.env.CI ? "" : "npm run build && "}python3 -c "import http.server, socketserver, functools; socketserver.TCPServer.request_queue_size = 256; handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory='out'); http.server.ThreadingHTTPServer(('127.0.0.1', ${PORT}), handler).serve_forever()"`,
    url: baseURL,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
})
