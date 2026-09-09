import type { Metadata } from "next"
import Link from "next/link"
import { notFound } from "next/navigation"
import { ArrowLeftIcon, ArrowRightIcon } from "lucide-react"

import { DocMarkdown } from "@/components/markdown"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { readDoc } from "@/lib/docs"
import { DOCS, docHref, findDoc } from "@/lib/docs-nav"
import { registry } from "@/lib/registry"

export const dynamicParams = false

export function generateStaticParams() {
  return DOCS.map((doc) => ({ slug: doc.slug }))
}

type Props = { params: Promise<{ slug: string }> }

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params
  const doc = findDoc(slug)
  return doc ? { title: doc.title, description: doc.description } : {}
}

export default async function DocPage({ params }: Props) {
  const { slug } = await params
  const doc = findDoc(slug)
  if (!doc) notFound()
  const index = DOCS.indexOf(doc)
  const previous = index > 0 ? DOCS[index - 1] : null
  const next = index < DOCS.length - 1 ? DOCS[index + 1] : null
  const source = readDoc(doc)
  const generated = doc.file.startsWith("content/")

  return (
    <article className="flex min-w-0 flex-col gap-6">
      <header className="flex flex-col gap-3">
        <div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
          <Link href="/docs/" className="hover:text-foreground">
            Docs
          </Link>
          <span aria-hidden>/</span>
          <span>{doc.group}</span>
        </div>
        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">{doc.title}</h1>
        <p className="max-w-[70ch] text-lg text-muted-foreground">{doc.description}</p>
        {generated ? (
          <div className="flex flex-wrap items-center gap-2 text-xs text-muted-foreground">
            <Badge variant="outline">From the repository</Badge>
            <span>
              This page is the repository&apos;s own document, copied by the site generator at build time.
            </span>
          </div>
        ) : null}
      </header>
      <DocMarkdown source={source} />
      <Separator />
      <nav className="flex flex-wrap items-center justify-between gap-2" aria-label="Docs pages">
        {previous ? (
          <Button variant="outline" render={<Link href={docHref(previous.slug)} />} nativeButton={false}>
            <ArrowLeftIcon data-icon="inline-start" />
            {previous.title}
          </Button>
        ) : (
          <span />
        )}
        {next ? (
          <Button variant="outline" render={<Link href={docHref(next.slug)} />} nativeButton={false}>
            {next.title}
            <ArrowRightIcon data-icon="inline-end" />
          </Button>
        ) : (
          <Button variant="outline" render={<a href={registry.repositoryURL} />} nativeButton={false}>
            The repository
            <ArrowRightIcon data-icon="inline-end" />
          </Button>
        )}
      </nav>
    </article>
  )
}
