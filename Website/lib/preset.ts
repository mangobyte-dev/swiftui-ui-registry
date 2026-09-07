// Preset codes: a RegistryTheme as a short shareable string.
//
// Mirrors RegistryKit's Preset.swift, the reference implementation behind
// `swiftui-registry preset`; the format rules live in docs/registry-spec.md
// and Registry/preset_vectors.json pins codes both must reproduce. Fields
// pack little-endian in FIELDS order into one integer,
// written in base62 behind a version letter. Numeric fields store their
// slider-grid index, so a code is exact on the tuning panel's grid.

export const PRESET_VERSION = "a"
const VERSIONS = ["a"]
const ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
const MAX_LENGTH = 22

export const ACCENTS = [
  "system", "ink", "blue", "indigo", "purple", "pink", "red", "orange",
  "yellow", "green", "mint", "teal", "cyan", "brown", "custom",
] as const
export type Accent = (typeof ACCENTS)[number]

export type NumericKey =
  | "surfaceOpacity"
  | "borderOpacity"
  | "borderWidth"
  | "emphasizedBorderWidth"
  | "compactRadius"
  | "controlRadius"
  | "cardRadius"
  | "compactSpacing"
  | "standardSpacing"
  | "sectionSpacing"
  | "controlHorizontalPadding"
  | "disabledOpacity"

export type PresetTuning = Record<NumericKey, number> & {
  accent: Accent
  darkLabelOnAccent: boolean
  /** #RRGGBB, present only when the accent is custom. */
  customAccent?: string
  /** #RRGGBB for dark appearance, or null; present only when the accent is custom. */
  customAccentDark?: string | null
}

export type NumericField = {
  key: NumericKey
  bits: number
  minimum: number
  step: number
  count: number
  decimals: number
  label: string
}

/** The slider grid of every numeric knob, in codec order after accent and label. */
export const NUMERIC_FIELDS: NumericField[] = [
  { key: "surfaceOpacity", bits: 6, minimum: 0, step: 0.005, count: 41, decimals: 3, label: "Surface opacity" },
  { key: "borderOpacity", bits: 5, minimum: 0, step: 0.01, count: 31, decimals: 2, label: "Border opacity" },
  { key: "borderWidth", bits: 3, minimum: 0.5, step: 0.5, count: 6, decimals: 1, label: "Border width" },
  { key: "emphasizedBorderWidth", bits: 3, minimum: 1, step: 0.5, count: 7, decimals: 1, label: "Emphasized border" },
  { key: "compactRadius", bits: 4, minimum: 0, step: 1, count: 13, decimals: 0, label: "Compact radius" },
  { key: "controlRadius", bits: 5, minimum: 0, step: 1, count: 23, decimals: 0, label: "Control radius" },
  { key: "cardRadius", bits: 6, minimum: 0, step: 1, count: 33, decimals: 0, label: "Card radius" },
  { key: "compactSpacing", bits: 4, minimum: 4, step: 1, count: 13, decimals: 0, label: "Compact spacing" },
  { key: "standardSpacing", bits: 5, minimum: 8, step: 1, count: 25, decimals: 0, label: "Standard spacing" },
  { key: "sectionSpacing", bits: 6, minimum: 12, step: 1, count: 37, decimals: 0, label: "Section spacing" },
  { key: "controlHorizontalPadding", bits: 5, minimum: 8, step: 1, count: 17, decimals: 0, label: "Control padding" },
  { key: "disabledOpacity", bits: 4, minimum: 0.2, step: 0.05, count: 13, decimals: 2, label: "Disabled opacity" },
]

export function maximum(field: NumericField): number {
  return roundTo(field.minimum + (field.count - 1) * field.step, field.decimals)
}

/** RegistryTheme() with no arguments. */
export const DEFAULT_TUNING: PresetTuning = {
  accent: "system",
  darkLabelOnAccent: false,
  surfaceOpacity: 0.055,
  borderOpacity: 0.08,
  borderWidth: 1,
  emphasizedBorderWidth: 2,
  compactRadius: 6,
  controlRadius: 8,
  cardRadius: 16,
  compactSpacing: 8,
  standardSpacing: 16,
  sectionSpacing: 24,
  controlHorizontalPadding: 12,
  disabledOpacity: 0.5,
}

function roundTo(value: number, decimals: number): number {
  const scale = 10 ** decimals
  return Math.round(value * scale) / scale
}

function fieldIndex(field: NumericField, value: number): number {
  const index = Math.round((value - field.minimum) / field.step)
  return Math.max(0, Math.min(field.count - 1, index))
}

/** Snaps a value to its field's slider grid, the value a code can carry. */
export function snap(field: NumericField, value: number): number {
  return roundTo(field.minimum + fieldIndex(field, value) * field.step, field.decimals)
}

export function isPresetCode(value: string): boolean {
  if (typeof value !== "string" || value.length < 2 || value.length > MAX_LENGTH) return false
  if (!VERSIONS.includes(value[0])) return false
  for (let position = 1; position < value.length; position += 1) {
    if (!ALPHABET.includes(value[position])) return false
  }
  return true
}

/** The code inside pasted text: bare, or behind a `--preset` flag. */
export function presetCodeIn(text: string): string | null {
  let candidate = text.trim()
  const flagged = candidate.match(/^--preset\s+(\S+)$/)
  if (flagged) candidate = flagged[1]
  return isPresetCode(candidate) ? candidate : null
}

function toBase62(number: bigint): string {
  if (number === BigInt(0)) return "0"
  const base = BigInt(62)
  let digits = ""
  let remaining = number
  while (remaining > BigInt(0)) {
    digits = ALPHABET[Number(remaining % base)] + digits
    remaining /= base
  }
  return digits
}

function fromBase62(text: string): bigint {
  let number = BigInt(0)
  for (const character of text) {
    number = number * BigInt(62) + BigInt(ALPHABET.indexOf(character))
  }
  return number
}

function rgbBits(hex: string | undefined | null): bigint {
  const match = /^#([0-9A-Fa-f]{6})$/.exec(hex ?? "")
  if (!match) throw new Error(`a custom accent must be #RRGGBB, not ${JSON.stringify(hex)}`)
  return BigInt(parseInt(match[1], 16))
}

function hex(bits: bigint): string {
  return "#" + Number(bits & BigInt(0xffffff)).toString(16).toUpperCase().padStart(6, "0")
}

export function encodePreset(tuning: PresetTuning): string {
  let bits = BigInt(0)
  let offset = 0
  const put = (index: number, width: number) => {
    bits |= BigInt(index) << BigInt(offset)
    offset += width
  }
  const accentIndex = ACCENTS.indexOf(tuning.accent)
  if (accentIndex < 0) throw new Error(`unknown accent ${tuning.accent}`)
  put(accentIndex, 4)
  put(tuning.darkLabelOnAccent ? 1 : 0, 1)
  for (const field of NUMERIC_FIELDS) {
    put(fieldIndex(field, tuning[field.key]), field.bits)
  }
  if (tuning.accent === "custom") {
    bits |= rgbBits(tuning.customAccent) << BigInt(offset)
    offset += 24
    if (tuning.customAccentDark) {
      put(1, 1)
      bits |= rgbBits(tuning.customAccentDark) << BigInt(offset)
      offset += 24
    } else {
      put(0, 1)
    }
  }
  return PRESET_VERSION + toBase62(bits)
}

export function decodePreset(code: string): PresetTuning | null {
  if (!isPresetCode(code)) return null
  const bits = fromBase62(code.slice(1))
  let offset = 0
  const take = (width: number) => {
    const value = Number((bits >> BigInt(offset)) & ((BigInt(1) << BigInt(width)) - BigInt(1)))
    offset += width
    return value
  }
  const accentIndex = take(4)
  if (accentIndex >= ACCENTS.length) return null
  const tuning = { ...DEFAULT_TUNING, accent: ACCENTS[accentIndex], darkLabelOnAccent: take(1) === 1 }
  for (const field of NUMERIC_FIELDS) {
    const index = take(field.bits)
    if (index >= field.count) return null
    tuning[field.key] = roundTo(field.minimum + index * field.step, field.decimals)
  }
  if (tuning.accent === "custom") {
    tuning.customAccent = hex(bits >> BigInt(offset))
    offset += 24
    if (take(1) === 1) {
      tuning.customAccentDark = hex(bits >> BigInt(offset))
      offset += 24
    } else {
      tuning.customAccentDark = null
    }
  }
  return tuning
}

export function randomTuning(): PresetTuning {
  const pick = (count: number) => Math.floor(Math.random() * count)
  const tuning: PresetTuning = {
    ...DEFAULT_TUNING,
    accent: ACCENTS[pick(ACCENTS.length)],
    darkLabelOnAccent: pick(2) === 1,
  }
  for (const field of NUMERIC_FIELDS) {
    tuning[field.key] = roundTo(field.minimum + pick(field.count) * field.step, field.decimals)
  }
  if (tuning.accent === "custom") {
    tuning.customAccent = hex(BigInt(pick(0x1000000)))
    tuning.customAccentDark = pick(2) === 1 ? hex(BigInt(pick(0x1000000))) : null
  }
  return tuning
}

// MARK: Swift

const ACCENT_SWIFT: Partial<Record<Accent, string>> = { ink: ".primary" }
for (const accent of ACCENTS) {
  if (accent !== "system" && accent !== "ink" && accent !== "custom") ACCENT_SWIFT[accent] = `.${accent}`
}

function points(value: number): string {
  return Number.isInteger(value) ? String(value) : value.toFixed(1)
}

function channels(hex: string): [string, string, string] {
  const bits = Number(rgbBits(hex))
  return [16, 8, 0].map((shift) => (((bits >> shift) & 0xff) / 255).toFixed(3)) as [string, string, string]
}

function colorSource(hex: string, ui: boolean): string {
  const [red, green, blue] = channels(hex)
  return ui
    ? `UIColor(red: ${red}, green: ${green}, blue: ${blue}, alpha: 1)`
    : `Color(red: ${red}, green: ${green}, blue: ${blue})`
}

/** The `RegistryTheme(...)` call, one argument per line, as the Showcase's Copy Swift writes it. */
export function initializerLines(tuning: PresetTuning): string[] {
  const lines = ["RegistryTheme("]
  if (tuning.accent === "custom" && tuning.customAccentDark && tuning.customAccent) {
    lines.push(
      "    accent: Color(uiColor: UIColor { traits in",
      "        traits.userInterfaceStyle == .dark",
      `            ? ${colorSource(tuning.customAccentDark, true)}`,
      `            : ${colorSource(tuning.customAccent, true)}`,
      "    }),"
    )
  } else if (tuning.accent === "custom" && tuning.customAccent) {
    lines.push(`    accent: ${colorSource(tuning.customAccent, false)},`)
  } else if (ACCENT_SWIFT[tuning.accent]) {
    lines.push(`    accent: ${ACCENT_SWIFT[tuning.accent]},`)
  }
  const onAccent =
    tuning.accent === "ink" ? "Color(uiColor: .systemBackground)" : tuning.darkLabelOnAccent ? ".black" : ".white"
  lines.push(
    `    onAccent: ${onAccent},`,
    `    surface: .primary.opacity(${tuning.surfaceOpacity.toFixed(3)}),`,
    `    border: .primary.opacity(${tuning.borderOpacity.toFixed(3)}),`,
    `    disabledOpacity: ${tuning.disabledOpacity.toFixed(3)},`,
    "    metrics: RegistryMetrics(",
    `        compactSpacing: ${points(tuning.compactSpacing)},`,
    `        standardSpacing: ${points(tuning.standardSpacing)},`,
    `        sectionSpacing: ${points(tuning.sectionSpacing)},`,
    `        controlHorizontalPadding: ${points(tuning.controlHorizontalPadding)},`,
    `        borderWidth: ${points(tuning.borderWidth)},`,
    `        emphasizedBorderWidth: ${points(tuning.emphasizedBorderWidth)},`,
    `        compactRadius: ${points(tuning.compactRadius)},`,
    `        controlRadius: ${points(tuning.controlRadius)},`,
    `        cardRadius: ${points(tuning.cardRadius)}`,
    "    )",
    ")"
  )
  return lines
}

/** The snippet to paste, in the tuning panel's Copy Swift shape. */
export function swiftSource(tuning: PresetTuning): string {
  const lines = initializerLines(tuning)
  lines[0] = "let theme = " + lines[0]
  lines.push("", "// Apply once at the root of your scene; every registry item below inherits it.", "ContentView()", "    .registryTheme(theme)")
  return lines.join("\n")
}

export function applyCommand(code: string): string {
  return `swiftui-registry preset apply ${code} --destination Sources/YourFeature/Components`
}

// MARK: Presets and colors

/** The six foundation presets (RegistryTheme.swift) as tunings. */
export const PRESETS: { name: string; slug: string; tuning: PresetTuning }[] = [
  { name: "System", slug: "system", tuning: { ...DEFAULT_TUNING } },
  { name: "Graphite", slug: "graphite", tuning: { ...DEFAULT_TUNING, accent: "ink", surfaceOpacity: 0.05, borderOpacity: 0.1 } },
  { name: "Indigo", slug: "indigo", tuning: { ...DEFAULT_TUNING, accent: "indigo" } },
  { name: "Rose", slug: "rose", tuning: { ...DEFAULT_TUNING, accent: "pink" } },
  { name: "Emerald", slug: "emerald", tuning: { ...DEFAULT_TUNING, accent: "green" } },
  { name: "Amber", slug: "amber", tuning: { ...DEFAULT_TUNING, accent: "yellow", darkLabelOnAccent: true } },
  { name: "Mango", slug: "mango", tuning: { ...DEFAULT_TUNING, accent: "custom", customAccent: "#FFA033", customAccentDark: "#FFB84D", darkLabelOnAccent: true, surfaceOpacity: 0.07, borderOpacity: 0, compactRadius: 10, controlRadius: 14, cardRadius: 24, sectionSpacing: 28, controlHorizontalPadding: 16, disabledOpacity: 0.4 } },
]

export function presetMatching(tuning: PresetTuning): (typeof PRESETS)[number] | undefined {
  const code = encodePreset(tuning)
  return PRESETS.find((preset) => encodePreset(preset.tuning) === code)
}

/**
 * The SwiftUI system colors as they resolve on the pinned iPhone 17, iOS 27
 * simulator, measured 2026-09-05 with Color.resolve(in:) in light and dark
 * environments (identical to UIColor.system*). `ink` is `.primary`, the label
 * color; `system` is the app tint, system blue in the Showcase.
 */
export const IOS_COLORS: Record<Exclude<Accent, "custom">, { light: string; dark: string }> = {
  system: { light: "#0088FF", dark: "#0091FF" },
  ink: { light: "#000000", dark: "#FFFFFF" },
  blue: { light: "#0088FF", dark: "#0091FF" },
  indigo: { light: "#6155F5", dark: "#6D7CFF" },
  purple: { light: "#CB30E0", dark: "#DB34F2" },
  pink: { light: "#FF2D55", dark: "#FF375F" },
  red: { light: "#FF383C", dark: "#FF4245" },
  orange: { light: "#FF8D28", dark: "#FF9230" },
  yellow: { light: "#FFCC00", dark: "#FFD600" },
  green: { light: "#34C759", dark: "#30D158" },
  mint: { light: "#00C8B3", dark: "#00DAC3" },
  teal: { light: "#00C3D0", dark: "#00D2E0" },
  cyan: { light: "#00C0E8", dark: "#3CD3FE" },
  brown: { light: "#AC7F5E", dark: "#B78A66" },
}

export const ACCENT_TITLES: Record<Accent, string> = {
  system: "System",
  ink: "Ink",
  blue: "Blue",
  indigo: "Indigo",
  purple: "Purple",
  pink: "Pink",
  red: "Red",
  orange: "Orange",
  yellow: "Yellow",
  green: "Green",
  mint: "Mint",
  teal: "Teal",
  cyan: "Cyan",
  brown: "Brown",
  custom: "Custom",
}

/** The accent as a CSS color for an appearance. */
export function accentColor(tuning: PresetTuning, appearance: "light" | "dark"): string {
  if (tuning.accent === "custom") {
    return (appearance === "dark" ? tuning.customAccentDark : null) ?? tuning.customAccent ?? "#000000"
  }
  return IOS_COLORS[tuning.accent][appearance]
}

/** The label drawn on accent fills. */
export function onAccentColor(tuning: PresetTuning, appearance: "light" | "dark"): string {
  if (tuning.accent === "ink") return appearance === "dark" ? "#000000" : "#FFFFFF"
  return tuning.darkLabelOnAccent ? "#000000" : "#FFFFFF"
}
