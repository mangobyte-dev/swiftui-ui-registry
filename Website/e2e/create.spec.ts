import { test, expect, openStudio, studioCode, setColorInput } from "./fixtures"

// The Create studio's controls, read from components/create-studio.tsx. Every
// control that writes the theme is exercised; the shape of the assertion is
// "the shared preset code in the code bar changed", since the code is the
// studio's single output and it decodes back through the tool and the Showcase.

// The twelve numeric sliders in NUMERIC_FIELDS order (preset.ts). Each is a
// labelled role=group wrapping a role=slider range input.
const NUMERIC_SLIDERS = [
  "Surface opacity",
  "Border opacity",
  "Border width",
  "Emphasized border",
  "Compact radius",
  "Control radius",
  "Card radius",
  "Compact spacing",
  "Standard spacing",
  "Section spacing",
  "Control padding",
  "Disabled opacity",
]

async function nudgeSlider(
  page: import("@playwright/test").Page,
  label: string
) {
  const thumb = page
    .getByRole("group", { name: label, exact: true })
    .getByRole("slider")
  await thumb.focus()
  const now = Number(await thumb.getAttribute("aria-valuenow"))
  const max = Number(await thumb.getAttribute("aria-valuemax"))
  await page.keyboard.press(now < max ? "ArrowRight" : "ArrowLeft")
}

test("each numeric slider changes the preset code with the keyboard", async ({
  page,
}) => {
  await openStudio(page)
  let previous = await studioCode(page)
  for (const label of NUMERIC_SLIDERS) {
    await nudgeSlider(page, label)
    const current = expect
      .poll(() => studioCode(page), {
        message: `slider "${label}" should change the code`,
      })
      .not.toBe(previous)
    await current
    previous = await studioCode(page)
  }
})

test("a slider-built code decodes back through the Open preset dialog", async ({
  page,
}) => {
  await openStudio(page)
  // Move a couple of sliders so the code is non-default, then read it.
  await nudgeSlider(page, "Card radius")
  await nudgeSlider(page, "Section spacing")
  const built = await studioCode(page)

  // Reset clears it, then Open decodes the built code back onto the studio.
  await page.getByRole("button", { name: "Reset", exact: true }).click()
  await expect.poll(() => studioCode(page)).not.toBe(built)
  await page.getByRole("button", { name: "Open", exact: true }).click()
  const dialog = page.getByRole("dialog")
  await dialog.getByLabel("Preset code").fill(built)
  await dialog.getByRole("button", { name: "Open", exact: true }).click()
  await expect.poll(() => studioCode(page)).toBe(built)
})

test("accent choices and the custom light/dark pair", async ({ page }) => {
  await openStudio(page)
  const start = await studioCode(page)

  // A preset accent swatch (the Accent radiogroup).
  await page.getByRole("radio", { name: "Green", exact: true }).click()
  await expect(
    page.getByRole("radio", { name: "Green", exact: true })
  ).toHaveAttribute("aria-checked", "true")
  await expect.poll(() => studioCode(page)).not.toBe(start)

  // The custom accent color, then a separate dark accent.
  await setColorInput(page, "#custom-accent", "#00FF00")
  const custom = await studioCode(page)
  await expect(
    page.getByRole("radio", { name: "Green", exact: true })
  ).toHaveAttribute("aria-checked", "false")
  await page.getByRole("switch", { name: "Separate dark accent" }).click()
  await expect(page.locator("#custom-accent-dark")).toBeVisible()
  await setColorInput(page, "#custom-accent-dark", "#0044AA")
  await expect.poll(() => studioCode(page)).not.toBe(custom)

  // The dark-label-on-accent switch.
  const beforeLabel = await studioCode(page)
  await page.getByRole("switch", { name: "Dark label on accent" }).click()
  await expect.poll(() => studioCode(page)).not.toBe(beforeLabel)
})

test("font design segmented control, and the export-only font family", async ({
  page,
}) => {
  await openStudio(page)
  const start = await studioCode(page)
  await page.getByRole("button", { name: "Rounded", exact: true }).click()
  await expect(
    page.getByRole("button", { name: "Rounded", exact: true })
  ).toHaveAttribute("aria-pressed", "true")
  await expect.poll(() => studioCode(page)).not.toBe(start)
  await page.getByRole("button", { name: "Serif", exact: true }).click()
  await expect(
    page.getByRole("button", { name: "Serif", exact: true })
  ).toHaveAttribute("aria-pressed", "true")

  // The custom font family never enters the code; it reaches only the export.
  const codeBeforeFamily = await studioCode(page)
  await page.getByLabel("Custom font family").fill("Avenir Next")
  await page.waitForTimeout(300)
  expect(await studioCode(page)).toBe(codeBeforeFamily)
  await page.getByRole("tab", { name: "Swift" }).click()
  await expect(page.getByText('Font.custom("Avenir Next"')).toBeVisible()
})

test("density buttons and the elevation slider", async ({ page }) => {
  await openStudio(page)
  await page.getByRole("button", { name: "Compact", exact: true }).click()
  await expect(
    page.getByRole("button", { name: "Compact", exact: true })
  ).toHaveAttribute("aria-pressed", "true")
  const afterCompact = await studioCode(page)
  await page.getByRole("button", { name: "Generous", exact: true }).click()
  await expect(
    page.getByRole("button", { name: "Generous", exact: true })
  ).toHaveAttribute("aria-pressed", "true")
  await expect.poll(() => studioCode(page)).not.toBe(afterCompact)

  // The elevation (surface step) slider.
  const beforeStep = await studioCode(page)
  const step = page
    .getByRole("group", { name: "Surface step", exact: true })
    .getByRole("slider")
  await step.focus()
  await page.keyboard.press("ArrowRight")
  await expect.poll(() => studioCode(page)).not.toBe(beforeStep)
})

test("chart palette", async ({ page }) => {
  await openStudio(page)
  const start = await studioCode(page)
  await page.getByRole("button", { name: "Spectrum", exact: true }).click()
  await expect(
    page.getByRole("button", { name: "Spectrum", exact: true })
  ).toHaveAttribute("aria-pressed", "true")
  await expect.poll(() => studioCode(page)).not.toBe(start)
  await page.getByRole("button", { name: "Monochrome", exact: true }).click()
  await expect(
    page.getByRole("button", { name: "Monochrome", exact: true })
  ).toHaveAttribute("aria-pressed", "true")
})

test("the three color pair rows", async ({ page }) => {
  await openStudio(page)

  // Background: on, a light color, a separate dark, a dark color.
  let previous = await studioCode(page)
  await page.getByRole("switch", { name: "Background", exact: true }).click()
  await expect.poll(() => studioCode(page)).not.toBe(previous)
  await expect(page.locator("#background-light")).toBeVisible()
  await setColorInput(page, "#background-light", "#123456")
  previous = await studioCode(page)
  // Only Background is on, so "Separate dark" is unambiguous.
  await page.getByRole("switch", { name: "Separate dark", exact: true }).click()
  await expect(page.locator("#background-dark")).toBeVisible()
  await setColorInput(page, "#background-dark", "#654321")
  await expect.poll(() => studioCode(page)).not.toBe(previous)

  // Foreground on.
  previous = await studioCode(page)
  await page.getByRole("switch", { name: "Foreground", exact: true }).click()
  await expect.poll(() => studioCode(page)).not.toBe(previous)

  // Secondary foreground on.
  previous = await studioCode(page)
  await page
    .getByRole("switch", { name: "Secondary foreground", exact: true })
    .click()
  await expect.poll(() => studioCode(page)).not.toBe(previous)
})

test("the export surfaces: code bar, Swift tab, and theme Package tab", async ({
  page,
}) => {
  await openStudio(page)

  // The code bar carries the preset code and its copy and link controls.
  await expect(page.getByText(/^--preset a13GkaOXWwIF/)).toBeVisible()
  await expect(page.getByRole("button", { name: "Copy preset" })).toBeVisible()
  await expect(page.getByRole("button", { name: "Copy link" })).toBeVisible()
  await expect(
    page.getByRole("button", { name: "Open", exact: true })
  ).toBeVisible()

  // The Swift tab holds the RegistryTheme initializer with the values.
  await page.getByRole("tab", { name: "Swift" }).click()
  await expect(page.getByText("let theme = RegistryTheme(")).toBeVisible()
  await expect(page.getByText("accent: .indigo")).toBeVisible()
  await expect(page.getByRole("button", { name: "Copy Swift" })).toBeVisible()

  // The Package tab holds both drop-in files. The filenames also appear in the
  // page's prose, so assert on each file's Copy control and its unique body.
  await page.getByRole("tab", { name: "Package" }).click()
  await expect(
    page.getByRole("button", { name: "Copy RegistryTheme+App.swift" })
  ).toBeVisible()
  await expect(
    page.getByRole("button", { name: "Copy THEME.md" })
  ).toBeVisible()
  await expect(page.getByText("extension RegistryTheme {")).toBeVisible()
  await expect(page.getByText("# Theme package")).toBeVisible()

  // The preview appearance toggle.
  await page.getByRole("tab", { name: "Preview" }).click()
  await page.getByRole("button", { name: "Dark", exact: true }).click()
  await expect(
    page.getByRole("button", { name: "Dark", exact: true })
  ).toHaveAttribute("aria-pressed", "true")
})

test("the ?preset= deep link shows the MANGO values", async ({ page }) => {
  await openStudio(page, "?preset=a74hGF01CVunaG0vzZJG")
  await expect(
    page.getByRole("button", { name: "Mango", exact: true })
  ).toHaveAttribute("aria-pressed", "true")
  await expect(page.getByText(/^--preset a74hGF01CVunaG0vzZJG/)).toBeVisible()
  await expect(page.locator("#custom-accent")).toHaveValue("#ffa033")
})

test("the preset buttons and Random rewrite the code", async ({ page }) => {
  await openStudio(page)
  const indigo = page.getByRole("button", { name: "Indigo", exact: true })
  await indigo.click()
  await expect(indigo).toHaveAttribute("aria-pressed", "true")
  const indigoCode = await studioCode(page)
  // The pinned Indigo code (Registry/preset_vectors.json).
  expect(indigoCode).toBe("a13GkaOXWwIF")
  const rose = page.getByRole("button", { name: "Rose", exact: true })
  await rose.click()
  await expect(rose).toHaveAttribute("aria-pressed", "true")
  expect(await studioCode(page)).toBe("a13GkaOXWwIH")
  await page.getByRole("button", { name: "Random", exact: true }).click()
  const random = await studioCode(page)
  expect(random).not.toBe("a13GkaOXWwIH")
  expect(random).toMatch(/^[ab][0-9A-Za-z]{1,47}$/)
})
