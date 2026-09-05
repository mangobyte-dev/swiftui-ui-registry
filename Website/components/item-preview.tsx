"use client"

import * as React from "react"
import { useTheme } from "next-themes"
import { MoonIcon, SunIcon } from "lucide-react"

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"
import { Empty, EmptyDescription, EmptyHeader, EmptyTitle } from "@/components/ui/empty"
import { asset } from "@/lib/registry"
import { cn } from "@/lib/utils"

type ItemPreviewProps = {
  name: string
  screenshots: { light: string | null; dark: string | null }
  codeLabel: string
  code: React.ReactNode
}

/** Preview and code tabs with a light/dark switch that follows the site theme until touched. */
export function ItemPreview({ name, screenshots, codeLabel, code }: ItemPreviewProps) {
  const { resolvedTheme } = useTheme()
  const [chosen, setChosen] = React.useState<string[] | null>(null)
  const appearance = chosen?.[0] ?? (resolvedTheme === "dark" ? "dark" : "light")
  const image = appearance === "dark" ? screenshots.dark : screenshots.light

  return (
    <Tabs defaultValue="preview" className="gap-0 overflow-hidden rounded-xl border">
      <div className="flex min-w-0 items-center justify-between gap-2 border-b bg-muted/50 px-2 py-1.5">
        <TabsList>
          <TabsTrigger value="preview">Preview</TabsTrigger>
          <TabsTrigger value="code">{codeLabel}</TabsTrigger>
        </TabsList>
        <ToggleGroup
          value={[appearance]}
          onValueChange={(value: string[]) => value.length && setChosen(value)}
          aria-label="Preview appearance"
          variant="outline"
          size="sm"
        >
          <ToggleGroupItem value="light" aria-label="Light">
            <SunIcon />
          </ToggleGroupItem>
          <ToggleGroupItem value="dark" aria-label="Dark">
            <MoonIcon />
          </ToggleGroupItem>
        </ToggleGroup>
      </div>
      <TabsContent
        value="preview"
        className={cn(
          "flex justify-center p-3 sm:p-8",
          appearance === "dark" ? "bg-[#0b0b0d]" : "bg-[#f4f4f6]"
        )}
      >
        {image ? (
          // The capture is the real Showcase on iPhone 17; next/image is not needed for a static export.
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={asset(image)}
            alt={`${name}, ${appearance}`}
            className="h-auto w-full max-w-[560px] rounded-xl border shadow-lg"
          />
        ) : (
          <Empty>
            <EmptyHeader>
              <EmptyTitle>No capture yet</EmptyTitle>
              <EmptyDescription>
                Run <code>python3 Scripts/capture_previews.py {name}</code>.
              </EmptyDescription>
            </EmptyHeader>
          </Empty>
        )}
      </TabsContent>
      <TabsContent value="code" className="[&>div]:max-h-[560px] [&>div]:overflow-auto [&>div]:rounded-none [&>div]:border-0">
        {code}
      </TabsContent>
    </Tabs>
  )
}
