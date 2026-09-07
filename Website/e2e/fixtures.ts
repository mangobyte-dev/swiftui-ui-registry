import { test as base, expect, type Page } from "@playwright/test"

// A console message that is the local static host dropping a TCP connection,
// not a site fault. The suite serves the static export with `python3 -m
// http.server` (AGENTS.md's website line and the brief's webServer): its
// listen backlog is 5, and two parallel Playwright workers plus Chromium's
// per-host connection fan-out overflow it at navigation, so the browser logs
// `Failed to load resource: net::ERR_CONNECTION_RESET` for an asset it then
// has on disk. The reset text is disjoint from a real failure: a missing file
// is `... status of 404`, a script fault is a `pageerror`, and neither string
// appears here, so this predicate cannot hide a site defect. This is the one
// documented exception to the console-clean contract; nothing else is allowed.
const TRANSPORT_RESET = [
  "net::ERR_CONNECTION_RESET",
  "net::ERR_SOCKET_NOT_CONNECTED",
  "The network connection was lost", // WebKit's wording for the same reset
]

function isStaticHostReset(text: string): boolean {
  return (
    text.startsWith("Failed to load resource") &&
    TRANSPORT_RESET.some((needle) => text.includes(needle))
  )
}

/** Records console errors, warnings, and uncaught page errors for a test. */
class ConsoleWatch {
  readonly problems: string[] = []
  attach(page: Page) {
    page.on("console", (message) => {
      const type = message.type()
      if (type !== "error" && type !== "warning") return
      const text = message.text()
      if (isStaticHostReset(text)) return
      this.problems.push(`console.${type}: ${text}`)
    })
    page.on("pageerror", (error) => {
      this.problems.push(`pageerror: ${error.message}`)
    })
  }
}

/**
 * Every test runs on a page whose console must stay clean: no console.error,
 * no console.warning, no uncaught exception. The check runs after the test body
 * and fails the test if anything arrived. The ⌘K search crash and the WebKit
 * `history.replaceState` crash both surfaced as page errors, so this guard is
 * the regression itself.
 */
export const test = base.extend<{ watch: ConsoleWatch }>({
  watch: [
    async ({ page }, use) => {
      const watch = new ConsoleWatch()
      watch.attach(page)
      await use(watch)
      expect(
        watch.problems,
        `the page logged console errors/warnings or threw:\n${watch.problems.join("\n")}`
      ).toEqual([])
    },
    { auto: true },
  ],
})

export { expect }

// The four page kinds the search regression must cover.
export const PAGE_KINDS: { name: string; path: string }[] = [
  { name: "home", path: "/" },
  { name: "item", path: "/items/button/" },
  { name: "themes", path: "/themes/" },
  { name: "create", path: "/create/" },
]

/** The preset code shown in the studio's code bar, without the flag. */
export async function studioCode(page: Page): Promise<string> {
  const line = await page
    .getByText(/^--preset /)
    .first()
    .innerText()
  return line.replace("--preset ", "").trim()
}

/**
 * Open the studio and wait for it to hydrate. The Create page renders a
 * Suspense skeleton in the static HTML (it reads useSearchParams), so every
 * control appears only after client hydration; the Reset button is the marker.
 * Two iOS Showcase suites share this machine, so the wait is generous.
 */
export async function openStudio(page: Page, query = ""): Promise<void> {
  await page.goto(`/create/${query}`, { waitUntil: "commit" })
  await page
    .getByRole("button", { name: "Reset", exact: true })
    .waitFor({ state: "visible", timeout: 60_000 })
}

/** Open the ⌘K dialog with the search button, retrying until the app hydrates. */
export async function openSearchWithButton(page: Page) {
  const combobox = page.getByRole("combobox")
  await expect(async () => {
    await page.getByRole("button", { name: "Search items" }).click()
    await expect(combobox).toBeVisible({ timeout: 1_500 })
  }).toPass({ timeout: 45_000 })
  return combobox
}

/** Set a native color input the way a user's picker does, so React's onChange fires. */
export async function setColorInput(
  page: Page,
  selector: string,
  value: string
) {
  await page
    .locator(selector)
    .evaluate((element: HTMLInputElement, next: string) => {
      const setter = Object.getOwnPropertyDescriptor(
        window.HTMLInputElement.prototype,
        "value"
      )!.set!
      setter.call(element, next)
      element.dispatchEvent(new Event("input", { bubbles: true }))
      element.dispatchEvent(new Event("change", { bubbles: true }))
    }, value)
}
