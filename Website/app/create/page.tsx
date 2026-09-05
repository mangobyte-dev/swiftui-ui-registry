import { Suspense } from "react"
import type { Metadata } from "next"

import { CreateStudio } from "@/components/create-studio"
import { Skeleton } from "@/components/ui/skeleton"

export const metadata: Metadata = {
  title: "Create",
  description:
    "Compose a RegistryTheme from the Showcase's tuning knobs, watch the tokens, and hand the result to the Showcase, the installer, or an agent as one preset code.",
}

export default function CreatePage() {
  return (
    <div className="flex flex-col gap-8">
      <header className="flex flex-col gap-3">
        <p className="text-xs font-semibold tracking-widest text-muted-foreground uppercase">Create</p>
        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">Compose a theme, share a code</h1>
        <p className="max-w-[62ch] text-lg text-muted-foreground">
          Every knob of the Showcase&apos;s tuning panel, packed into one short preset code. The same code opens on a
          device, writes <code>RegistryTheme+App.swift</code> through the installer, and decodes for an agent.
        </p>
      </header>
      <Suspense fallback={<Skeleton className="h-[640px] w-full rounded-xl" />}>
        <CreateStudio />
      </Suspense>
    </div>
  )
}
