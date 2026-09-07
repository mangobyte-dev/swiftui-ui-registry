import { test, expect, openStudio, studioCode } from "./fixtures"

// Regression for c128dbe "Stop the Create page from crashing iOS Safari":
// WebKit throws a SecurityError past 100 history.replaceState calls in 10
// seconds, and the App Router mirrors each of the studio's own calls, so a
// dragged slider used to cross the limit and throw onto the error screen. The
// studio now rewrites the address 400 ms after the tuning settles
// (create-studio.tsx around line 107). Driving more than 120 changes inside 10
// seconds must not throw, and the address must end with the settled code.
test("rapid tuning changes never trip WebKit's replaceState limit", async ({
  page,
}, testInfo) => {
  test.skip(
    testInfo.project.name !== "webkit-iphone",
    "The SecurityError is WebKit-only; Chromium has no per-10-second history.replaceState cap."
  )

  await openStudio(page)
  const thumb = page
    .getByRole("group", { name: "Section spacing", exact: true })
    .getByRole("slider")
  await thumb.focus()

  const started = Date.now()
  // Oscillate so every keypress changes the value (and so the code), 130 > 120.
  for (let i = 0; i < 130; i += 1) {
    await page.keyboard.press(i % 2 === 0 ? "ArrowLeft" : "ArrowRight")
  }
  const elapsed = Date.now() - started
  expect(
    elapsed,
    "the 130 changes must land inside WebKit's 10-second window"
  ).toBeLessThan(10_000)

  // After the 400 ms settle, the address carries the final code. (A thrown
  // SecurityError would already have failed the test through the console-clean
  // fixture, which records every pageerror.)
  const settled = await studioCode(page)
  await expect.poll(() => new URL(page.url()).search).toBe(`?preset=${settled}`)
})
