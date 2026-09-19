import type { Metadata } from "next"
import Link from "next/link"
import { notFound } from "next/navigation"

import { DocMarkdown, slugify } from "@/components/markdown"
import { PrevNext } from "@/components/prev-next"
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

/** The h2/h3 headings of a markdown body, with ids matching what DocMarkdown renders. */
function tocFromMarkdown(
  source: string
): { id: string; text: string; level: 2 | 3 }[] {
  const toc: { id: string; text: string; level: 2 | 3 }[] = []
  let inFence = false
  for (const line of source.split("\n")) {
    if (/^\s*```/.test(line)) {
      inFence = !inFence
      continue
    }
    if (inFence) continue
    const match = /^(#{2,3})\s+(.*)$/.exec(line)
    if (!match) continue
    const text = match[2].replace(/[*`_]/g, "").trim()
    toc.push({ id: slugify(text), text, level: match[1].length as 2 | 3 })
  }
  return toc
}

export default async function DocPage({ params }: Props) {
  const { slug } = await params
  const doc = findDoc(slug)
  if (!doc) notFound()
  const index = DOCS.indexOf(doc)
  const previous = index > 0 ? DOCS[index - 1] : null
  const next = index < DOCS.length - 1 ? DOCS[index + 1] : null
  const source = readDoc(doc)
  const toc = tocFromMarkdown(source)

  return (
    <div className="grid grid-cols-1 gap-x-10 min-[1080px]:grid-cols-[minmax(0,1fr)_244px]">
      <article className="flex min-w-0 flex-col gap-6">
        <header className="flex flex-col gap-3">
          <div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
            <Link href="/docs/" className="hover:text-foreground">
              Docs
            </Link>
            <span aria-hidden>/</span>
            <span>{doc.group}</span>
          </div>
          <h1 className="border-b pb-4 text-[32px] leading-[1.1] font-semibold tracking-[-0.015em] sm:text-[40px] sm:leading-[1.08]">
            {doc.title}
          </h1>
        </header>
        <DocMarkdown source={source} />
        <PrevNext
          previous={
            previous
              ? { href: docHref(previous.slug), title: previous.title }
              : null
          }
          next={
            next
              ? { href: docHref(next.slug), title: next.title }
              : { href: registry.repositoryURL, title: "The repository" }
          }
        />
      </article>

      <aside className="max-[1079px]:hidden">
        {toc.length ? (
          <nav
            aria-label="On this page"
            className="sticky top-[76px] max-h-[calc(100vh-76px)] overflow-auto py-1 text-[13px]"
          >
            <div className="mb-2.5 text-[11px] font-semibold tracking-[0.05em] text-muted-foreground uppercase">
              On this page
            </div>
            <ul className="flex flex-col gap-1.5">
              {toc.map((entry) => (
                <li
                  key={`${entry.level}-${entry.id}`}
                  className={entry.level === 3 ? "pl-3.5" : undefined}
                >
                  <a
                    href={`#${entry.id}`}
                    className="text-muted-foreground hover:text-primary"
                  >
                    {entry.text}
                  </a>
                </li>
              ))}
            </ul>
          </nav>
        ) : null}
      </aside>
    </div>
  )
}
