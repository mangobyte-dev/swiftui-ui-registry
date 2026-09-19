import { codeToHtml } from "shiki"

import { CopyButton } from "@/components/copy-button"
import { pfeTheme } from "@/lib/shiki-theme"
import { cn } from "@/lib/utils"

type CodeBlockProps = {
  code: string
  /** A shiki language id; an unknown one renders as plain text. */
  language?: string
  className?: string
}

/** The dark copy button that reads on the code box, in either color mode. */
const DARK_COPY = "border-white/15 bg-white/5 text-white/70 hover:bg-white/10 hover:text-white"

/** Highlighted at build time with one fixed theme: the box is dark in both color modes. */
export async function CodeBlock({ code, language = "swift", className }: CodeBlockProps) {
  const html = await codeToHtml(code, { lang: language, theme: pfeTheme }).catch(() =>
    codeToHtml(code, { lang: "text", theme: pfeTheme })
  )
  return (
    <div
      className={cn(
        "group/code relative min-w-0 max-w-full overflow-hidden rounded-[12px] bg-[#1f1f24]",
        className
      )}
    >
      <div className="absolute top-2.5 right-2.5">
        <CopyButton text={code} className={DARK_COPY} />
      </div>
      <div
        className="max-w-full overflow-x-auto px-5 py-[18px] pr-14 font-mono text-[13.5px] leading-[1.6] [&_code]:whitespace-pre [&_pre]:!m-0 [&_pre]:!bg-transparent"
        dangerouslySetInnerHTML={{ __html: html }}
      />
    </div>
  )
}
