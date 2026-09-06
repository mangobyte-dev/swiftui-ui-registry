import { registry, type RegistryItem } from "./registry"

/** Lowercase word tokens, the same split the registry's search uses. */
function tokens(text: string): string[] {
  return text.toLowerCase().split(/[^a-z0-9]+/).filter(Boolean)
}

/**
 * Ranks items for the ⌘K typeahead with the registry's own weights: a term on the name
 * scores 30, on an alias 25, on a tag 20, on the description or kind 5, an exact name adds
 * 100, and every term must match somewhere. Terms match token prefixes because a
 * typeahead sees partial words; the command line matches whole tokens.
 */
export function rankItems(query: string, items: RegistryItem[] = registry.items): RegistryItem[] {
  const terms = tokens(query)
  if (terms.length === 0) return items
  const exact = query.trim().toLowerCase()
  const scored = items.flatMap((item) => {
    const fields: [string[], number][] = [
      [tokens(item.name), 30],
      [tokens(item.aliases.join(" ")), 25],
      [tokens(item.tags.join(" ")), 20],
      [[...tokens(item.description), item.kind], 5],
    ]
    let score = 0
    for (const term of terms) {
      const field = fields.find(([words]) => words.some((word) => word.startsWith(term)))
      if (!field) return []
      score += field[1]
    }
    if (exact === item.name) score += 100
    return [{ item, score }]
  })
  return scored
    .sort((a, b) => b.score - a.score || a.item.name.localeCompare(b.item.name))
    .map(({ item }) => item)
}
