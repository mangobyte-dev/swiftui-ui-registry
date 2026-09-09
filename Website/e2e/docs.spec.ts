import { test, expect } from "./fixtures"

import { DOCS } from "../lib/docs-nav"

// Every Docs page renders its title from the nav entry and its markdown body
// with a clean console (the fixture's contract); the changelog names the
// current beta, and a repository link inside a document resolves to the site
// or to GitHub, never to a relative path that would 404 on the static host.
for (const doc of DOCS) {
  test(`docs page ${doc.slug} renders`, async ({ page }) => {
    await page.goto(`/docs/${doc.slug}/`, { waitUntil: "commit" })
    await expect(page.getByRole("heading", { level: 1, name: doc.title, exact: true })).toBeVisible({
      timeout: 20_000,
    })
    const body = page.locator(".markdown")
    await expect(body).toBeVisible()
    const relative = await body.locator("a[href]:not([href^='http']):not([href^='/']):not([href^='#'])").count()
    expect(relative, "every link is absolute on the static host").toBe(0)
  })
}

test("the changelog names the current beta", async ({ page }) => {
  await page.goto("/docs/changelog/", { waitUntil: "commit" })
  await expect(page.getByRole("heading", { level: 2, name: /^0\.3\.0/ })).toBeVisible({ timeout: 20_000 })
})

test("the docs index links every page", async ({ page }) => {
  await page.goto("/docs/", { waitUntil: "commit" })
  for (const doc of DOCS) {
    await expect(page.getByRole("link", { name: new RegExp(`^${doc.title}`) }).first()).toBeVisible({
      timeout: 20_000,
    })
  }
})
