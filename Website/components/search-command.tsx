"use client"

import * as React from "react"
import { useRouter } from "next/navigation"
import { SearchIcon } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import { KINDS, registry } from "@/lib/registry"

/** ⌘K search over every item's name, description, and tags. */
export function SearchCommand() {
  const [open, setOpen] = React.useState(false)
  const router = useRouter()

  React.useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      if (event.key === "k" && (event.metaKey || event.ctrlKey)) {
        event.preventDefault()
        setOpen((value) => !value)
      }
    }
    window.addEventListener("keydown", onKeyDown)
    return () => window.removeEventListener("keydown", onKeyDown)
  }, [])

  return (
    <>
      <Button
        variant="outline"
        size="sm"
        className="min-w-0 flex-1 justify-start text-muted-foreground sm:w-56 sm:flex-none"
        onClick={() => setOpen(true)}
      >
        <SearchIcon data-icon="inline-start" />
        Search items
        <kbd className="ml-auto hidden rounded border bg-muted px-1.5 font-mono text-[10px] sm:inline">
          ⌘K
        </kbd>
      </Button>
      <CommandDialog open={open} onOpenChange={setOpen} title="Search items" description="Jump to an item">
        <CommandInput placeholder="Search components, blocks, recipes" />
        <CommandList>
          <CommandEmpty>No items match.</CommandEmpty>
          {KINDS.map(({ kind, title }) => (
            <CommandGroup key={kind} heading={title}>
              {registry.items
                .filter((item) => item.kind === kind)
                .map((item) => (
                  <CommandItem
                    key={item.name}
                    value={`${item.name} ${item.description} ${item.tags.join(" ")}`}
                    onSelect={() => {
                      setOpen(false)
                      router.push(`/items/${item.name}/`)
                    }}
                  >
                    <span className="font-medium">{item.name}</span>
                    <span className="truncate text-muted-foreground">{item.description}</span>
                  </CommandItem>
                ))}
            </CommandGroup>
          ))}
        </CommandList>
      </CommandDialog>
    </>
  )
}
