import Markdown from "react-markdown"
import remarkGfm from "remark-gfm"

import { CodeBlock } from "@/components/code-block"
import { asset, registry } from "@/lib/registry"

/** Repository paths the documents link to, and the site page for each. */
const DOC_ROUTES: Record<string, string> = {
  "README.md": "/docs/installation/",
  "CHANGELOG.md": "/docs/changelog/",
  "docs/philosophy.md": "/docs/introduction/",
  "docs/architecture.md": "/docs/architecture/",
  "docs/registry-spec.md": "/docs/registry-spec/",
  "docs/mango.md": "/docs/mango/",
  "docs/visual-testing.md": "/docs/visual-testing/",
  "docs/catalog/index.md": "/items/button/",
  "Website/": "/",
}

/** A link in a repository document: a site page, an absolute URL, or the file on GitHub. */
export function resolveDocLink(raw: string): string {
  if (/^(https?:|mailto:|#)/.test(raw)) return raw
  const clean = raw.replace(/^\.\//, "")
  const [pathPart, hash] = clean.split("#")
  const route = DOC_ROUTES[pathPart]
  if (route) return asset(route) + (hash ? `#${hash}` : "")
  if (pathPart.startsWith("/")) return asset(pathPart)
  return `${registry.repositoryURL}/blob/main/${pathPart}${hash ? `#${hash}` : ""}`
}

const SHIKI_LANGUAGES: Record<string, string> = {
  swift: "swift",
  sh: "bash",
  bash: "bash",
  zsh: "bash",
  shell: "bash",
  json: "json",
  jsonc: "jsonc",
  ts: "ts",
  tsx: "tsx",
  yaml: "yaml",
  yml: "yaml",
  ruby: "ruby",
  rb: "ruby",
  text: "text",
  txt: "text",
  markdown: "markdown",
  md: "markdown",
}

/** The changelog's section names, each with the color its marker takes. */
const SECTION_TONES: Record<string, string> = {
  Added: "bg-emerald-500",
  Changed: "bg-sky-500",
  Fixed: "bg-amber-500",
  Removed: "bg-rose-500",
  "Known limitations": "bg-rose-500",
}

const VERSION_HEADING = /^(\d+\.\d+\.\d+)(.*)$/

function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-")
}

function textOf(children: React.ReactNode): string {
  if (typeof children === "string") return children
  if (Array.isArray(children)) return children.map(textOf).join("")
  if (children && typeof children === "object" && "props" in children) {
    return textOf((children as { props: { children?: React.ReactNode } }).props.children)
  }
  return ""
}

/** Markdown from the repository, rendered with the site's chrome. */
export function DocMarkdown({ source }: { source: string }) {
  return (
    <div className="markdown">
      <Markdown
        remarkPlugins={[remarkGfm]}
        components={{
          h2: ({ children }) => {
            const text = textOf(children)
            const version = VERSION_HEADING.exec(text)
            if (!version) return <h2 id={slugify(text)}>{children}</h2>
            return (
              <h2 id={slugify(text)} className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                <span className="version-tag">{version[1]}</span>
                <span className="text-base font-medium text-muted-foreground">{version[2].trim()}</span>
              </h2>
            )
          },
          h3: ({ children }) => {
            const text = textOf(children)
            const tone = SECTION_TONES[text]
            return (
              <h3 id={slugify(text)} className={tone ? "flex items-center gap-2" : undefined}>
                {tone ? <span aria-hidden className={`inline-block size-2.5 rounded-full ${tone}`} /> : null}
                {children}
              </h3>
            )
          },
          a: ({ href, children }) => {
            const target = resolveDocLink(href ?? "")
            const external = /^https?:/.test(target)
            return (
              <a href={target} rel={external ? "noreferrer" : undefined}>
                {children}
              </a>
            )
          },
          // eslint-disable-next-line @next/next/no-img-element
          img: ({ src, alt }) => <img src={asset(String(src ?? ""))} alt={alt ?? ""} loading="lazy" />,
          pre: ({ children }) => <>{children}</>,
          code: ({ className, children }) => {
            const match = /language-([\w-]+)/.exec(className ?? "")
            const text = textOf(children).replace(/\n$/, "")
            if (!match && !text.includes("\n")) return <code>{text}</code>
            const language = SHIKI_LANGUAGES[match?.[1] ?? "text"] ?? "text"
            return <CodeBlock code={text} language={language} className="not-markdown my-4" />
          },
        }}
      >
        {source}
      </Markdown>
    </div>
  )
}
