import type { Metadata } from "next"
import Link from "next/link"
import { notFound } from "next/navigation"
import { ArrowLeftIcon, ArrowRightIcon } from "lucide-react"

import { CodeBlock } from "@/components/code-block"
import { ItemPreview } from "@/components/item-preview"
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { Table, TableBody, TableCell, TableRow } from "@/components/ui/table"
import { asset, findItem, installCommand, registry } from "@/lib/registry"

type Params = { name: string }

export function generateStaticParams(): Params[] {
  return registry.items.map((item) => ({ name: item.name }))
}

export async function generateMetadata({ params }: { params: Promise<Params> }): Promise<Metadata> {
  const { name } = await params
  const item = findItem(name)
  return { title: item?.name ?? name, description: item?.description }
}

export default async function ItemPage({ params }: { params: Promise<Params> }) {
  const { name } = await params
  const item = findItem(name)
  if (!item) notFound()

  const isRecipe = item.kind === "recipe"
  const index = registry.items.findIndex((candidate) => candidate.name === item.name)
  const previous = registry.items[index - 1]
  const next = registry.items[index + 1]

  return (
    <article className="flex flex-col gap-10">
      <header className="flex flex-col gap-3">
        <Badge variant="outline" className="w-fit uppercase">
          {item.kind}
        </Badge>
        <h1 className="break-words text-3xl font-bold tracking-tight sm:text-4xl">{item.name}</h1>
        <p className="max-w-[62ch] text-base text-muted-foreground sm:text-lg">{item.description}</p>
        <div className="flex flex-wrap gap-1.5">
          {item.tags.map((tag) => (
            <Badge key={tag} variant="secondary">
              {tag}
            </Badge>
          ))}
        </div>
      </header>

      <ItemPreview
        name={item.name}
        screenshots={item.screenshots}
        codeLabel={isRecipe ? "Snippet" : "Source"}
        code={<CodeBlock code={isRecipe ? item.usage : (item.source ?? "")} />}
      />

      {item.wideScreenshots.light && item.wideScreenshots.dark ? (
        <section className="flex flex-col gap-3">
          <h2 className="text-xl font-semibold tracking-tight">On iPad</h2>
          <p className="text-sm text-muted-foreground">
            The same installed source at a regular width; the block adapts its rows and metrics without a separate layout.
          </p>
          <div className="overflow-hidden rounded-xl border bg-muted">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={asset(item.wideScreenshots.light)} alt={`${item.name} on iPad, light`} loading="lazy" className="w-full dark:hidden" />
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={asset(item.wideScreenshots.dark)} alt={`${item.name} on iPad, dark`} loading="lazy" className="hidden w-full dark:block" />
          </div>
        </section>
      ) : null}

      <section className="flex flex-col gap-3">
        <h2 className="text-xl font-semibold tracking-tight">Install</h2>
        {isRecipe ? (
          <Alert>
            <AlertTitle>Nothing to install</AlertTitle>
            <AlertDescription>Copy the snippet below; the native API is the entire treatment.</AlertDescription>
          </Alert>
        ) : (
          <>
            <p className="text-sm text-muted-foreground">
              With the swiftui-registry tool (<code>brew install mangobyte-dev/tap/swiftui-registry</code>):
            </p>
            <CodeBlock language="bash" code={installCommand(item.name)} />
            <p className="text-sm text-muted-foreground">
              Installs in order:{" "}
              {item.installOrder.map((member, position) => (
                <span key={member.name}>
                  {position > 0 ? ", " : ""}
                  <Link href={`/items/${member.name}/`} className="font-medium text-foreground underline-offset-4 hover:underline">
                    {member.name}
                  </Link>{" "}
                  {member.version}
                </span>
              ))}
              . Point <code>--destination</code> at a folder inside the consuming target&apos;s sources.
            </p>
            <Accordion>
              <AccordionItem value="requirement">
                <AccordionTrigger>Package requirement</AccordionTrigger>
                <AccordionContent className="flex flex-col gap-3">
                  {item.requirements.map((requirement) => (
                    <div key={requirement.instruction} className="flex flex-col gap-3">
                      <p className="text-sm">Then {requirement.instruction}.</p>
                      <CodeBlock code={requirement.manifest} />
                      <p className="text-sm text-muted-foreground">{requirement.xcode}.</p>
                    </div>
                  ))}
                </AccordionContent>
              </AccordionItem>
            </Accordion>
          </>
        )}
      </section>

      <section className="flex flex-col gap-3">
        <h2 className="text-xl font-semibold tracking-tight">Usage</h2>
        <CodeBlock code={item.usage} />
      </section>

      {isRecipe && item.docs ? (
        <section className="flex flex-col gap-3">
          <h2 className="text-xl font-semibold tracking-tight">Why native is enough</h2>
          <Prose text={item.docs} />
        </section>
      ) : null}

      <section className="flex flex-col gap-3">
        <h2 className="text-xl font-semibold tracking-tight">Accessibility contract</h2>
        <ul className="flex list-disc flex-col gap-1.5 pl-5 text-sm">
          {item.accessibility.map((note) => (
            <li key={note}>{note}</li>
          ))}
        </ul>
      </section>

      <section className="flex flex-col gap-3">
        <h2 className="text-xl font-semibold tracking-tight">Details</h2>
        <div className="overflow-x-auto rounded-xl border">
          <Table>
            <TableBody>
              <TableRow>
                <TableCell className="w-32 text-muted-foreground sm:w-40">Kind</TableCell>
                <TableCell>{item.kind}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell className="text-muted-foreground">Version</TableCell>
                <TableCell>{item.version}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell className="text-muted-foreground">Platforms</TableCell>
                <TableCell>{item.platforms.join(", ")}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell className="text-muted-foreground">Dependencies</TableCell>
                <TableCell>
                  {item.dependencies.length
                    ? item.dependencies.map((dependency, position) => (
                        <span key={dependency}>
                          {position > 0 ? ", " : ""}
                          <Link href={`/items/${dependency}/`} className="underline-offset-4 hover:underline">
                            {dependency}
                          </Link>
                        </span>
                      ))
                    : "none"}
                </TableCell>
              </TableRow>
              <TableRow>
                <TableCell className="text-muted-foreground">Source</TableCell>
                <TableCell>
                  {item.sourceURL ? (
                    <a href={item.sourceURL} className="break-all underline-offset-4 hover:underline">
                      {item.sourcePath}
                    </a>
                  ) : (
                    "none (native guidance)"
                  )}
                </TableCell>
              </TableRow>
              {item.previewName ? (
                <TableRow>
                  <TableCell className="text-muted-foreground">Xcode preview</TableCell>
                  <TableCell>
                    <code>{item.previewName}</code>
                  </TableCell>
                </TableRow>
              ) : null}
            </TableBody>
          </Table>
        </div>
      </section>

      <Separator />
      <nav className="flex justify-between">
        {previous ? (
          <Button variant="outline" render={<Link href={`/items/${previous.name}/`} />} nativeButton={false}>
            <ArrowLeftIcon data-icon="inline-start" />
            {previous.name}
          </Button>
        ) : (
          <span />
        )}
        {next ? (
          <Button variant="outline" render={<Link href={`/items/${next.name}/`} />} nativeButton={false}>
            {next.name}
            <ArrowRightIcon data-icon="inline-end" />
          </Button>
        ) : (
          <span />
        )}
      </nav>
    </article>
  )
}

/** Prose with `backtick` spans rendered as code. */
function Prose({ text }: { text: string }) {
  const parts = text.split("`")
  return (
    <p className="text-sm leading-relaxed">
      {parts.map((part, position) =>
        position % 2 ? (
          <code key={position} className="rounded bg-muted px-1 py-0.5 font-mono text-[0.85em]">
            {part}
          </code>
        ) : (
          <span key={position}>{part}</span>
        )
      )}
    </p>
  )
}
