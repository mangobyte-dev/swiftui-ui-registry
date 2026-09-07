import { test, expect, PAGE_KINDS, openSearchWithButton } from "./fixtures"

// Regression for 77914cf "Fix the website search crash and ranking": the ⌘K
// dialog's cmdk input and list were not wrapped in a Command root, so opening
// search on any page (the Create page included) threw into the router's error
// screen. Each page kind opens search with the button and with the keyboard
// shortcut, ranks a query, and lands on the right item page; the console-clean
// fixture is the crash guard (the throw arrived as a pageerror).
for (const kind of PAGE_KINDS) {
  test(`search opens and navigates from the ${kind.name} page`, async ({
    page,
  }) => {
    await page.goto(kind.path, { waitUntil: "commit" })

    // The button opens the dialog (and the retry waits out hydration).
    const combobox = await openSearchWithButton(page)
    await page.keyboard.press("Escape")
    await expect(combobox).toBeHidden()

    // The ⌘K shortcut opens the same dialog.
    await page.keyboard.press("ControlOrMeta+k")
    await expect(combobox).toBeVisible()

    // A query returns ranked results; the exact-name match ranks first.
    await combobox.fill("button")
    const firstResult = page.getByRole("option").first()
    await expect(firstResult).toContainText("button")

    // Enter selects the top result and lands on its item page.
    await page.keyboard.press("Enter")
    await page.waitForURL("**/items/button/", { timeout: 30_000 })
    await expect(
      page.getByRole("heading", { name: "button", exact: true })
    ).toBeVisible()
  })
}
