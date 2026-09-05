import Link from "next/link"
import { ArrowRightIcon } from "lucide-react"

import { CodeBlock } from "@/components/code-block"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { KINDS, asset, itemsOfKind, registry } from "@/lib/registry"

const PACKAGE_SNIPPET = `// Package.swift
dependencies: [
    .package(url: "https://github.com/mangobyte-dev/swiftui-ui-registry.git", .upToNextMinor(from: "0.1.0"))
]

// In the consuming target's dependencies:
.product(name: "SwiftUIRegistryFoundations", package: "swiftui-ui-registry")`

export default function HomePage() {
  const featured = [...itemsOfKind("block"), ...itemsOfKind("component")]
  return (
    <div className="flex flex-col gap-16">
      <section className="flex flex-col gap-6 pt-6">
        <div className="flex flex-wrap gap-2">
          <Badge variant="secondary">Version 0</Badge>
          <Badge variant="secondary">iOS 26 and later</Badge>
          <Badge variant="secondary">MIT</Badge>
        </div>
        <h1 className="max-w-[18ch] text-3xl font-bold tracking-tight sm:text-5xl">
          Native-first SwiftUI you copy and own.
        </h1>
        <p className="max-w-[62ch] text-lg text-muted-foreground">
          A registry of SwiftUI product UI in the spirit of shadcn/ui. Search a local catalog, copy real
          Swift source into your app, set the theme once, and own every line. Apple controls stay visible at
          the call site; the registry only styles and composes them.
        </p>
        <div className="flex flex-wrap gap-2">
          <Button render={<Link href="/items/button/" />} nativeButton={false}>
            Browse components
            <ArrowRightIcon data-icon="inline-end" />
          </Button>
          <Button variant="outline" render={<Link href="/create/" />} nativeButton={false}>
            Create a theme
          </Button>
          <Button variant="outline" render={<Link href="/themes/" />} nativeButton={false}>
            Themes
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
        <h2 className="text-2xl font-semibold tracking-tight">Set up once, use it everywhere</h2>
        <ol className="grid gap-4 md:grid-cols-3">
          <li>
            <Card className="h-full">
              <CardHeader>
                <CardTitle>1. Add the foundations package</CardTitle>
                <CardDescription>
                  One small package carries the theme contract: accent, surfaces, borders, semantic colors,
                  and metrics.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <CodeBlock code={PACKAGE_SNIPPET} />
              </CardContent>
            </Card>
          </li>
          <li>
            <Card className="h-full">
              <CardHeader>
                <CardTitle>2. Apply a theme at your root</CardTitle>
                <CardDescription>
                  Pick a preset, or compose one on the Create page and apply its code. Every item below
                  inherits it, and native controls follow through the tint.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <CodeBlock code={"ContentView()\n    .registryTheme(.graphite)"} />
              </CardContent>
            </Card>
          </li>
          <li>
            <Card className="h-full">
              <CardHeader>
                <CardTitle>3. Install what you need</CardTitle>
                <CardDescription>
                  Copy an item and its dependency closure into your target. A receipt makes later updates
                  merge instead of overwrite.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <CodeBlock
                  language="bash"
                  code="python3 Scripts/install.py auth-form --destination Sources/YourFeature/Components"
                />
              </CardContent>
            </Card>
          </li>
        </ol>
      </section>

      <section className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-semibold tracking-tight">Blocks and components</h2>
          <p className="text-muted-foreground">
            Every capture is the real installed source rendered by the Showcase on iPhone 17, iOS 27.
          </p>
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
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
            Where a one-line Apple API is the entire treatment, the registry says so instead of wrapping it.
          </p>
        </div>
        <div className="grid gap-3 sm:grid-cols-2">
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
