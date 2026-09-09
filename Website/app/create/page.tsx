import { Suspense } from "react"
import type { Metadata } from "next"

import { CreateStudio } from "@/components/create-studio"
import { Skeleton } from "@/components/ui/skeleton"

export const metadata: Metadata = {
  title: "Create",
  description:
    "Compose a RegistryTheme from Showcase's tuning knobs, watching tokens live; hand it to Showcase, installer, or agent as one preset code.",
}

export default function CreatePage() {
  return (
    <div className="flex flex-col gap-8">
      <header className="flex flex-col gap-3">
        <p className="text-xs font-semibold tracking-widest text-muted-foreground uppercase">Create</p>
        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">Compose a theme, share a code</h1>
        <p className="max-w-[62ch] text-lg text-muted-foreground">
          One code packs every knob of the Showcase&apos;s tuning panel: opens on device, writes{" "}
          <code>RegistryTheme+App.swift</code> through the installer, decodes for an agent.
        </p>
      </header>
      <Suspense fallback={<Skeleton className="h-[640px] w-full rounded-xl" />}>
        <CreateStudio />
      </Suspense>
    </div>
  )
}
