import { codeToHtml } from "shiki"

import { CopyButton } from "@/components/copy-button"
import { cn } from "@/lib/utils"

type CodeBlockProps = {
  code: string
  language?: "swift" | "bash"
  className?: string
}

/** Highlighted at build time; light and dark themes ride as CSS variables. */
export async function CodeBlock({ code, language = "swift", className }: CodeBlockProps) {
  const html = await codeToHtml(code, {
    lang: language,
    themes: { light: "github-light", dark: "github-dark" },
    defaultColor: false,
  })
  return (
    <div
      className={cn(
        "group/code relative overflow-hidden rounded-xl border bg-card text-sm",
        className
      )}
    >
      <div className="absolute top-2 right-2">
        <CopyButton text={code} />
      </div>
      <div
        className="overflow-x-auto p-4 pr-16 font-mono text-[13px] leading-relaxed [&_pre]:!bg-transparent [&_code]:whitespace-pre"
        dangerouslySetInnerHTML={{ __html: html }}
      />
    </div>
  )
}
