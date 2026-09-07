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

  // Count every history.replaceState call the page makes, so the assertion is
  // about the mechanism (one rewrite after the tuning settles) and not about
  // how fast this machine can press keys: a CI runner took 14 s for the 130
  // presses, outside WebKit's 10-second window, which proved nothing either way.
  await page.addInitScript(() => {
    const original = history.replaceState.bind(history)
    const counter = { calls: 0 }
    ;(
      window as unknown as { __replaceStateCalls: { calls: number } }
    ).__replaceStateCalls = counter
    history.replaceState = (
      ...args: Parameters<typeof history.replaceState>
    ) => {
      counter.calls += 1
      return original(...args)
    }
  })
  await openStudio(page)
  const thumb = page
    .getByRole("group", { name: "Section spacing", exact: true })
    .getByRole("slider")
  await thumb.focus()
  const before = await page.evaluate(
    () =>
      (window as unknown as { __replaceStateCalls: { calls: number } })
        .__replaceStateCalls.calls
  )

  // Oscillate so every keypress changes the value (and so the code), 130 > 120.
  for (let i = 0; i < 130; i += 1) {
    await page.keyboard.press(i % 2 === 0 ? "ArrowLeft" : "ArrowRight")
  }

  // After the 400 ms settle, the address carries the final code. (A thrown
  // SecurityError would already have failed the test through the console-clean
  // fixture, which records every pageerror.)
  const settled = await studioCode(page)
  await expect.poll(() => new URL(page.url()).search).toBe(`?preset=${settled}`)
  const calls = await page.evaluate(
    () =>
      (window as unknown as { __replaceStateCalls: { calls: number } })
        .__replaceStateCalls.calls
  )
  // 130 changes must collapse into a handful of address rewrites; a page that
  // rewrote on every change would report more than a hundred here.
  expect(
    calls - before,
    "history.replaceState calls during 130 changes"
  ).toBeLessThan(20)
})
