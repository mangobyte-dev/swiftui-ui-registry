"use client"

import * as React from "react"
import { useRouter } from "next/navigation"
import { SearchIcon } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Command,
  CommandDialog,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import { KINDS, registry, type RegistryItem } from "@/lib/registry"
import { rankItems } from "@/lib/search"

/** ⌘K search over every item's name, aliases, tags, and description. */
export function SearchCommand() {
  const [open, setOpen] = React.useState(false)
  const [query, setQuery] = React.useState("")
  const router = useRouter()
  // cmdk 1.1.1 never reorders its groups (its group selector looks up the wrong data-value),
  // so the dialog ranks the items itself and renders one ordered list for a query.
  const results = React.useMemo(() => rankItems(query), [query])

  function openItem(item: RegistryItem) {
    setOpen(false)
    router.push(`/items/${item.name}/`)
  }

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
      <CommandDialog
        open={open}
        onOpenChange={(value) => {
          setOpen(value)
          if (!value) setQuery("")
        }}
        title="Search items"
        description="Jump to an item"
      >
        <Command shouldFilter={false}>
          <CommandInput
            placeholder="Search components, blocks, recipes"
            value={query}
            onValueChange={setQuery}
          />
          <CommandList>
            <CommandEmpty>No items match.</CommandEmpty>
            {query.trim() === "" ? (
              KINDS.map(({ kind, title }) => (
                <CommandGroup key={kind} heading={title}>
                  {registry.items
                    .filter((item) => item.kind === kind)
                    .map((item) => (
                      <CommandItem key={item.name} value={item.name} onSelect={() => openItem(item)}>
                        <span className="font-medium">{item.name}</span>
                        <span className="truncate text-muted-foreground">{item.description}</span>
                      </CommandItem>
                    ))}
                </CommandGroup>
              ))
            ) : (
              <CommandGroup heading="Results">
                {results.map((item) => (
                  <CommandItem key={item.name} value={item.name} onSelect={() => openItem(item)}>
                    <span className="font-medium">{item.name}</span>
                    <span className="shrink-0 text-xs text-muted-foreground">{item.kind}</span>
                    <span className="truncate text-muted-foreground">{item.description}</span>
                  </CommandItem>
                ))}
              </CommandGroup>
            )}
          </CommandList>
        </Command>
      </CommandDialog>
    </>
  )
}
