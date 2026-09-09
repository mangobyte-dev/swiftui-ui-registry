/**
 * The Docs section, in reading order. A page's body is markdown: either a
 * repository document the site-data generator copies into `content/docs/`
 * (never edited here) or a hand-written page under `docs/`.
 */
export type DocGroup = "Get started" | "Guides" | "Reference"

export type DocPage = {
  slug: string
  title: string
  description: string
  group: DocGroup
  /** Path relative to the `Website/` directory. */
  file: string
}

export const DOCS: DocPage[] = [
  {
    slug: "introduction",
    title: "Introduction",
    description: "What the registry is, the principles every item follows, and what it deliberately leaves to Apple.",
    group: "Get started",
    file: "content/docs/philosophy.md",
  },
  {
    slug: "installation",
    title: "Installation",
    description: "Add the package, theme once, install an item, use it, and tune it on the device. Five minutes.",
    group: "Get started",
    file: "docs/installation.md",
  },
  {
    slug: "design-surface",
    title: "Design surface",
    description: "The on-device tuner: a floating panel over your running app that selects items, moves every token live, and exports the result.",
    group: "Guides",
    file: "docs/design-surface.md",
  },
  {
    slug: "cli",
    title: "CLI",
    description: "Every swiftui-registry command: search, describe, plan, install, diff, update, info, presets, validate, and the generators.",
    group: "Guides",
    file: "docs/cli.md",
  },
  {
    slug: "mcp",
    title: "MCP server",
    description: "The same operations as tools over stdio for an agent: search, describe, plan, diff, install, and the preset tools.",
    group: "Guides",
    file: "docs/mcp.md",
  },
  {
    slug: "mango",
    title: "MANGO design system",
    description: "The sample design system built on the registry, and the template a team follows to build its own.",
    group: "Guides",
    file: "content/docs/mango.md",
  },
  {
    slug: "architecture",
    title: "Architecture",
    description: "The hybrid model: a small foundations package you depend on, and item source you copy and own.",
    group: "Reference",
    file: "content/docs/architecture.md",
  },
  {
    slug: "registry-spec",
    title: "Registry specification",
    description: "The item document, the validator, resolution, receipts, the generators, and the preset code format.",
    group: "Reference",
    file: "content/docs/registry-spec.md",
  },
  {
    slug: "visual-testing",
    title: "Visual testing",
    description: "How the Showcase's pinned visual references and captures are made, compared, and replaced.",
    group: "Reference",
    file: "content/docs/visual-testing.md",
  },
  {
    slug: "changelog",
    title: "Changelog",
    description: "What shipped in each release, and the known limitations at the time.",
    group: "Reference",
    file: "content/docs/changelog.md",
  },
]

export const DOC_GROUPS: DocGroup[] = ["Get started", "Guides", "Reference"]

export function findDoc(slug: string): DocPage | undefined {
  return DOCS.find((doc) => doc.slug === slug)
}

export function docHref(slug: string): string {
  return `/docs/${slug}/`
}
