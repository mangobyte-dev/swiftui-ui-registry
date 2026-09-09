import type { Metadata } from "next"
import Link from "next/link"

import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { DOCS, DOC_GROUPS, docHref } from "@/lib/docs-nav"

export const metadata: Metadata = {
  title: "Docs",
  description: "How to install the registry, theme it, tune it on the device, drive the tool, and read its contracts.",
}

export default function DocsIndexPage() {
  return (
    <div className="flex flex-col gap-10">
      <header className="flex flex-col gap-3">
        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">Docs</h1>
        <p className="max-w-[70ch] text-lg text-muted-foreground">
          Start with the installation, then the on-device tuner, the tool, and the contracts the registry
          holds itself to. The reference pages are the repository&apos;s own documents.
        </p>
      </header>
      {DOC_GROUPS.map((group) => (
        <section key={group} className="flex flex-col gap-4">
          <h2 className="text-xl font-semibold tracking-tight">{group}</h2>
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            {DOCS.filter((doc) => doc.group === group).map((doc) => (
              <Link key={doc.slug} href={docHref(doc.slug)} className="min-w-0">
                <Card size="sm" className="h-full transition-colors hover:border-foreground/30">
                  <CardHeader>
                    <CardTitle>{doc.title}</CardTitle>
                    <CardDescription>{doc.description}</CardDescription>
                  </CardHeader>
                </Card>
              </Link>
            ))}
          </div>
        </section>
      ))}
    </div>
  )
}
