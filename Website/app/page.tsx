import Link from "next/link"
import { ArrowRightIcon } from "lucide-react"

import { CodeBlock } from "@/components/code-block"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { docHref } from "@/lib/docs-nav"
import { KINDS, asset, itemsOfKind, registry } from "@/lib/registry"

const COMPARISON_LAYERS = [
  { slug: "registry", title: "Registry" },
  { slug: "plain", title: "Stock" },
  { slug: "handmade", title: "Handmade" },
]

const COMPARISON_ROWS: { label: string; values: [string, string, string] }[] = [
  { label: "Lines written", values: ["223 (4 files)", "154 (3 files)", "585 (11 files)"] },
  { label: "Owned, not written", values: ["651 (7 items)", "0", "0"] },
  {
    label: "Protocols/modifiers",
    values: [
      "none",
      "none",
      "ButtonStyle, TextFieldStyle (_body), GroupBoxStyle, ToggleStyle, 3 ViewModifiers, environment key, theme (8 colors, 9 metrics)",
    ],
  },
  {
    label: "Look",
    values: ["coral (preset)", "stock controls", "same, byte-identical"],
  },
  {
    label: "Change accent everywhere",
    values: ["one value (RegistryTheme+App.swift) or new preset code", "not available", "one value, once plumbed"],
  },
  {
    label: "Updates",
    values: ["--update merges upstream, keeps edits", "nothing to update", "by hand"],
  },
  {
    label: "Accessibility built in",
    values: [
      "required icon-only labels, 44 pt hits, text-scaling boxes, VoiceOver switch, RTL/Dynamic Type previews",
      "whatever stock gives",
      "know it, rewrite it",
    ],
  },
  { label: "App launch, XCTApplicationLaunchMetric, 5 runs", values: ["2.97 s", "2.99 s", "2.98 s"] },
  { label: "5 tasks, complete, clear, XCTClockMetric, 3 runs", values: ["9.17 s", "15.59 s", "9.16 s"] },
  {
    label: "Skills",
    values: [
      "SwiftUI basics, one command",
      "SwiftUI basics",
      "style protocols, environment plumbing, Dynamic Type, accessibility, dark-mode color, RTL",
    ],
  },
]

const PACKAGE_SNIPPET = `// Package.swift
dependencies: [
    .package(url: "https://github.com/mangobyte-dev/swiftui-ui-registry.git", .upToNextMinor(from: "0.3.0"))
]

// In the consuming target's dependencies:
.product(name: "SwiftUIRegistryFoundations", package: "swiftui-ui-registry")`

export default function HomePage() {
  const featured = [...itemsOfKind("block"), ...itemsOfKind("component")]
  return (
    <div className="flex flex-col gap-16">
      <section className="flex flex-col gap-6 pt-6">
        <div className="flex flex-wrap gap-2">
          <Link href={docHref("changelog")}>
            <Badge>0.3.0 public beta</Badge>
          </Link>
          <Badge variant="secondary">iOS 26+</Badge>
          <Badge variant="secondary">MIT</Badge>
        </div>
        <h1 className="max-w-[18ch] text-3xl font-bold tracking-tight sm:text-5xl">
          Native-first SwiftUI you copy and own.
        </h1>
        <p className="max-w-[62ch] text-lg text-muted-foreground">
          A registry of SwiftUI product UI, like shadcn/ui. Search a local catalog, copy real source, theme
          once, own every line. Apple controls stay visible; the registry only styles and composes them.
        </p>
        <div className="flex flex-wrap gap-2">
          <Button render={<Link href={docHref("installation")} />} nativeButton={false}>
            Get started
            <ArrowRightIcon data-icon="inline-end" />
          </Button>
          <Button variant="outline" render={<Link href="/items/button/" />} nativeButton={false}>
            Browse components
          </Button>
          <Button variant="outline" render={<Link href="/create/" />} nativeButton={false}>
            Create theme
          </Button>
          <Button variant="ghost" render={<a href={registry.repositoryURL} />} nativeButton={false}>
            GitHub
          </Button>
        </div>
        <dl className="flex flex-wrap gap-8 pt-2">
          {KINDS.map(({ kind, title }) => (
            <div key={kind} className="flex flex-col">
              <dt className="text-2xl font-bold tabular-nums">{registry.counts[kind]}</dt>
              <dd className="text-sm text-muted-foreground">{title.toLowerCase()}</dd>
            </div>
          ))}
          <div className="flex flex-col">
            <dt className="text-2xl font-bold tabular-nums">{registry.presets.length}</dt>
            <dd className="text-sm text-muted-foreground">theme presets</dd>
          </div>
        </dl>
      </section>

      <section className="flex flex-col gap-4">
        <h2 className="text-2xl font-semibold tracking-tight">Set up once, use everywhere</h2>
        <ol className="grid grid-cols-1 gap-4 md:grid-cols-3">
          <li className="min-w-0">
            <Card className="h-full">
              <CardHeader>
                <CardTitle>1. Add foundations</CardTitle>
                <CardDescription>
                  One small package carries the theme contract: accent, surfaces, borders, semantic colors, metrics.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <CodeBlock code={PACKAGE_SNIPPET} />
              </CardContent>
            </Card>
          </li>
          <li className="min-w-0">
            <Card className="h-full">
              <CardHeader>
                <CardTitle>2. Theme the root</CardTitle>
                <CardDescription>
                  Pick a preset or compose on Create; items below inherit it, controls follow the tint.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <CodeBlock code={"ContentView()\n    .registryTheme(.graphite)"} />
              </CardContent>
            </Card>
          </li>
          <li className="min-w-0">
            <Card className="h-full">
              <CardHeader>
                <CardTitle>3. Install an item</CardTitle>
                <CardDescription>
                  Copies item + dependency closure to target; receipt merges updates, not overwrites.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <CodeBlock
                  language="bash"
                  code="swiftui-registry install auth-form --destination Sources/YourFeature/Components"
                />
              </CardContent>
            </Card>
          </li>
        </ol>
      </section>

      <section className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-semibold tracking-tight">Tune device</h2>
          <p className="max-w-[70ch] text-muted-foreground">
            New in 0.3.0: the design surface floats a panel over your running app. Select an item, it scopes
            to that item&apos;s tokens; move a knob and the app changes live. Export a preset or Swift code;
            release unchanged.
          </p>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-[1fr_2fr]">
          <figure className="flex min-w-0 flex-col gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={asset("/images/design-surface/iphone-card-light.png")}
              alt="Tuning card, Showcase, iPhone, outlined"
              loading="lazy"
              className="h-auto w-full rounded-xl border shadow-sm"
            />
            <figcaption className="text-sm text-muted-foreground">iPhone: stays where left.</figcaption>
          </figure>
          <figure className="flex min-w-0 flex-col gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={asset("/images/design-surface/ipad-column-light.png")}
              alt="Tuning panel, Showcase, iPad side column, buttons outlined"
              loading="lazy"
              className="h-auto w-full rounded-xl border shadow-sm"
            />
            <figcaption className="text-sm text-muted-foreground">iPad: docks into a column.</figcaption>
          </figure>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" render={<Link href={docHref("design-surface")} />} nativeButton={false}>
            Design surface
            <ArrowRightIcon data-icon="inline-end" />
          </Button>
          <Button variant="ghost" render={<Link href={docHref("changelog")} />} nativeButton={false}>
            What&apos;s new
          </Button>
        </div>
      </section>

      <section className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-semibold tracking-tight">You get</h2>
          <p className="text-muted-foreground">
            One todo-and-counter app, three UI layers, same reducers: registry, stock SwiftUI, handmade.
            Tested 2026-09-06, iPhone 17 simulator, iOS 27; see Examples/TodoCounter.
          </p>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
          {COMPARISON_LAYERS.map((layer) => (
            <figure key={layer.slug} className="flex flex-col gap-2">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src={asset(`/images/comparison/todos-${layer.slug}.png`)}
                alt={`Todos on the ${layer.title.toLowerCase()} layer`}
                className="h-auto w-full rounded-xl border shadow-sm"
              />
              <figcaption className="text-sm font-medium">{layer.title}</figcaption>
            </figure>
          ))}
        </div>
        <div className="overflow-x-auto rounded-lg border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-56"></TableHead>
                {COMPARISON_LAYERS.map((layer) => (
                  <TableHead key={layer.slug}>{layer.title}</TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody>
              {COMPARISON_ROWS.map((row) => (
                <TableRow key={row.label}>
                  <TableCell className="font-medium">{row.label}</TableCell>
                  {row.values.map((value, index) => (
                    <TableCell key={index} className="whitespace-normal align-top">
                      {value}
                    </TableCell>
                  ))}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
        <p className="text-sm text-muted-foreground">
          Runtime: registry vs handmade cost nothing extra, within noise. Stock&apos;s slower interaction: switch
          animation under UI automation, not rendering. Registry saves 585 lines and the skills, once per
          project, plus an update path.
        </p>
      </section>

      <section className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-semibold tracking-tight">Blocks and components</h2>
          <p className="text-muted-foreground">
            Installed source, rendered by Showcase, iPhone 17, iOS 27.
          </p>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {featured.map((item) => (
            <Link key={item.name} href={`/items/${item.name}/`} className="group">
              <Card className="h-full gap-0 overflow-hidden py-0 transition-colors group-hover:border-foreground/30">
                <div className="aspect-[4/3] overflow-hidden border-b bg-muted">
                  {item.screenshots.light ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={asset(item.screenshots.light)}
                      alt={`${item.name} preview`}
                      loading="lazy"
                      className="size-full object-cover object-top dark:hidden"
                    />
                  ) : null}
                  {item.screenshots.dark ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={asset(item.screenshots.dark)}
                      alt={`${item.name} preview, dark`}
                      loading="lazy"
                      className="hidden size-full object-cover object-top dark:block"
                    />
                  ) : null}
                </div>
                <CardHeader className="py-4">
                  <Badge variant="outline" className="w-fit">
                    {item.kind}
                  </Badge>
                  <CardTitle className="pt-1">{item.name}</CardTitle>
                  <CardDescription className="line-clamp-2">{item.description}</CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>
      </section>

      <section className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-semibold tracking-tight">Recipes</h2>
          <p className="text-muted-foreground">
            When a one-line Apple API suffices, the registry says so, not wraps it.
          </p>
        </div>
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
          {itemsOfKind("recipe").map((item) => (
            <Link key={item.name} href={`/items/${item.name}/`}>
              <Card size="sm" className="h-full transition-colors hover:border-foreground/30">
                <CardHeader>
                  <CardTitle>{item.name}</CardTitle>
                  <CardDescription>{item.description}</CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>
      </section>
    </div>
  )
}
