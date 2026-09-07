import type { Metadata } from "next"
import Link from "next/link"

import { CodeBlock } from "@/components/code-block"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { asset, registry } from "@/lib/registry"

export const metadata: Metadata = {
  title: "Themes",
  description:
    "One RegistryTheme applied at the scene root; presets and the live tuning panel.",
}

const TUNE_EXPORT = `let theme = RegistryTheme(
    accent: .primary,
    onAccent: Color(uiColor: .systemBackground),
    surface: .primary.opacity(0.050),
    border: .primary.opacity(0.100),
    disabledOpacity: 0.500,
    metrics: RegistryMetrics(
        compactSpacing: 8,
        standardSpacing: 16,
        sectionSpacing: 24,
        controlHorizontalPadding: 12,
        borderWidth: 1,
        emphasizedBorderWidth: 2,
        compactRadius: 6,
        controlRadius: 10,
        cardRadius: 18
    )
)

// Apply once at the root of your scene; every registry item below inherits it.
ContentView()
    .registryTheme(theme)`

const TOKENS: [string, string, string][] = [
  ["accent", "nil (app tint)", "every tinted item, through the subtree tint"],
  ["onAccent", ".white", "button, auth-form"],
  [
    "surface",
    ".primary.opacity(0.055)",
    "card, input, badge, select, textarea, avatar, alert, empty, every block",
  ],
  [
    "border",
    ".primary.opacity(0.08)",
    "card, input, badge, separator, select, textarea, checkbox, accordion",
  ],
  ["positive", ".green", "badge, progress, transaction-row, alert"],
  [
    "negative",
    ".red",
    "badge, button, input, textarea, transaction-row, alert, auth-form",
  ],
  ["disabledOpacity", "0.5", "button, checkbox, input, select, textarea"],
  ["metrics.compactSpacing", "8", "badge, label, every row"],
  ["metrics.standardSpacing", "16", "card, metric-card, every block"],
  ["metrics.sectionSpacing", "24", "blocks"],
  ["metrics.controlHorizontalPadding", "12", "input, select"],
  [
    "metrics.borderWidth / emphasizedBorderWidth",
    "1 / 2",
    "inputs at rest and focused or invalid",
  ],
  [
    "metrics.compactRadius / controlRadius / cardRadius",
    "6 / 8 / 16",
    "badge and checkbox / controls and alerts / cards",
  ],
  [
    "fontDesign",
    "nil (system)",
    "every text, applied by registryTheme with .fontDesign when set",
  ],
  [
    "surfaceStep",
    "0.02",
    "the elevation ladder, registrySurface(level:) and RegistrySurfaceLevel",
  ],
  ["chartPalette", ".accent", "chart, through chartForegroundStyleScale"],
  ["background", "nil (system background)", "the scene root, when set"],
  [
    "foreground",
    "nil (system label)",
    "the scene root; the secondary hierarchy derives from it",
  ],
  [
    "secondaryForeground",
    "nil (system secondary label)",
    "the scene root, paired with foreground when set",
  ],
]

export default function ThemesPage() {
  const mango = registry.presets.find((preset) => preset.slug === "mango")
  return (
    <div className="flex flex-col gap-12">
      <header className="flex flex-col gap-3">
        <p className="text-xs font-semibold tracking-widest text-muted-foreground uppercase">
          Themes
        </p>
        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">
          One modifier, every screen
        </h1>
        <p className="max-w-[62ch] text-lg text-muted-foreground">
          A <code>RegistryTheme</code> is a small value: an optional accent, the
          label color on top of it, the content surface, the hairline border,
          positive and negative colors, a disabled opacity, and the metrics.
          Apply it once with <code>.registryTheme(_:)</code> at your scene root.
          Items read the tokens from the environment; native controls follow the
          accent through the tint.
        </p>
      </header>

      <section className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-semibold tracking-tight">Presets</h2>
          <p className="text-muted-foreground">
            Starting points. Each is a plain <code>static let</code> you can
            copy and edit. Every card here is the first screen of the{" "}
            <Link href="/items/preview/">theme preview wall</Link> (the{" "}
            <code>preview</code> block, 33 cards) rendered under that preset on
            iPhone 17.
          </p>
        </div>
        <div className="grid gap-4 sm:grid-cols-2">
          {registry.presets.map((preset) => (
            <Card key={preset.slug} className="gap-0 overflow-hidden py-0">
              <div className="border-b bg-muted">
                {preset.screenshots.light ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={asset(preset.screenshots.light)}
                    alt={`${preset.name} preset, light`}
                    loading="lazy"
                    className="w-full dark:hidden"
                  />
                ) : null}
                {preset.screenshots.dark ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={asset(preset.screenshots.dark)}
                    alt={`${preset.name} preset, dark`}
                    loading="lazy"
                    className="hidden w-full dark:block"
                  />
                ) : null}
              </div>
              <CardHeader className="pt-4">
                <CardTitle>{preset.name}</CardTitle>
                <CardDescription>{preset.blurb}</CardDescription>
              </CardHeader>
              <CardContent className="pb-4">
                <CodeBlock
                  code={`ContentView()\n    .registryTheme(.${preset.slug})`}
                />
              </CardContent>
            </Card>
          ))}
        </div>
      </section>

      {mango ? (
        <section className="flex flex-col gap-4">
          <div className="flex flex-col gap-1">
            <h2 className="text-2xl font-semibold tracking-tight">
              MANGO, a design system built on the registry
            </h2>
            <p className="text-muted-foreground">
              The worked example of a brand on these items, and the template for
              building yours.
            </p>
          </div>
          <div className="grid gap-6 md:grid-cols-[minmax(0,1fr)_minmax(0,1.2fr)]">
            <div className="flex flex-col gap-4">
              <p className="max-w-[62ch] text-sm leading-relaxed">
                MANGO makes three choices and applies them once at the scene
                root: rounded type through <code>.fontDesign(.rounded)</code>,
                strokeless surfaces (border opacity zero, depth from a surface
                step), and one accent spent on the primary action. Two items are
                owned copies with edits, the button style with press feedback on
                a critically damped spring and the metric card with tabular
                digits. The preset is <code>.mango</code>, the code below opens
                it in Create, and the template document walks a team through
                doing the same for their brand.
              </p>
              <CodeBlock
                code={`ContentView()\n    .registryTheme(.mango)\n    .fontDesign(.rounded)`}
              />
              <CodeBlock
                code={`swiftui-registry preset apply ${mango.code} --destination Sources/YourFeature/Components`}
              />
              <p className="text-sm text-muted-foreground">
                <Link href={`/create/?preset=${mango.code}`}>
                  Open MANGO in Create
                </Link>
                {" · "}
                <a
                  href={`${registry.repositoryURL}/blob/main/docs/mango.md`}
                  target="_blank"
                  rel="noreferrer"
                >
                  Read the template, docs/mango.md
                </a>
              </p>
            </div>
            {mango.demoScreenshots.light ? (
              <div className="overflow-hidden rounded-xl border bg-muted">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={asset(mango.demoScreenshots.light)}
                  alt="The MANGO demo in the Showcase, light"
                  loading="lazy"
                  className="w-full dark:hidden"
                />
                {mango.demoScreenshots.dark ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={asset(mango.demoScreenshots.dark)}
                    alt="The MANGO demo in the Showcase, dark"
                    loading="lazy"
                    className="hidden w-full dark:block"
                  />
                ) : null}
              </div>
            ) : null}
          </div>
        </section>
      ) : null}

      <section className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-semibold tracking-tight">
            Tune it live
          </h2>
          <p className="text-muted-foreground">
            The Showcase&apos;s tuning panel is the theme creator, beside the
            catalog.
          </p>
        </div>
        <p className="max-w-[70ch] text-sm leading-relaxed">
          Every token is a slider or a swatch beside a live preview of the
          registry: accent and its label color, surface and border opacity,
          border widths, the three radii, the four spacings, the disabled
          opacity, plus appearance, text size, and right-to-left for checking
          the result. <strong>Copy Swift</strong> puts the exact initializer on
          the pasteboard, and <strong>Copy Code</strong> the preset code:
        </p>
        <CodeBlock code={TUNE_EXPORT} />
        <p className="text-sm text-muted-foreground">
          Open{" "}
          <code>Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace</code>,
          run the Showcase, and tap Tune in the strip above the tab bar. The
          panel stays beside the catalog, an inspector on iPad and a sheet the
          catalog remains interactive under on iPhone, so every demo shows the
          change as you make it. Copy Code puts the theme on the pasteboard as a
          preset code the <Link href="/create/">Create page</Link> and{" "}
          <code>swiftui-registry preset</code> both read. The preset captures
          above are the first screen of the{" "}
          <Link href="/items/preview/">theme preview wall</Link> (the{" "}
          <code>preview</code> block, 33 cards) rendered under each preset on
          iPhone 17.
        </p>
      </section>

      <section className="flex flex-col gap-4">
        <h2 className="text-2xl font-semibold tracking-tight">
          Every token, and who reads it
        </h2>
        <div className="overflow-x-auto rounded-xl border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Token</TableHead>
                <TableHead>Default</TableHead>
                <TableHead>Read by</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {TOKENS.map(([token, value, readers]) => (
                <TableRow key={token}>
                  <TableCell>
                    <code>{token}</code>
                  </TableCell>
                  <TableCell>
                    <code>{value}</code>
                  </TableCell>
                  <TableCell className="whitespace-normal text-muted-foreground">
                    {readers}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </section>
    </div>
  )
}
