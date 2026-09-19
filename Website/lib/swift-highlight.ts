import { createElement, type ReactNode } from "react"

/**
 * A zero-dependency Swift tokenizer ported from the wiki's build script
 * (build-wiki.py, highlight_swift). It emits React nodes, not HTML, so inline
 * code needs no dangerouslySetInnerHTML. The class names match the wiki's:
 * hl-kw hl-s hl-c hl-at hl-n hl-lit hl-ty hl-fn hl-p. An identifier is a type
 * when it starts uppercase, a function when the next non-space token is "(".
 */
const SWIFT_KW = new Set([
  "func",
  "let",
  "var",
  "class",
  "struct",
  "enum",
  "protocol",
  "extension",
  "actor",
  "typealias",
  "associatedtype",
  "import",
  "return",
  "if",
  "else",
  "guard",
  "for",
  "in",
  "while",
  "repeat",
  "switch",
  "case",
  "default",
  "break",
  "continue",
  "fallthrough",
  "do",
  "try",
  "catch",
  "throw",
  "throws",
  "rethrows",
  "defer",
  "async",
  "await",
  "self",
  "Self",
  "super",
  "init",
  "deinit",
  "subscript",
  "public",
  "private",
  "internal",
  "fileprivate",
  "open",
  "final",
  "override",
  "static",
  "mutating",
  "nonmutating",
  "some",
  "any",
  "where",
  "as",
  "is",
  "inout",
  "indirect",
  "lazy",
  "weak",
  "unowned",
  "get",
  "set",
  "willSet",
  "didSet",
  "nonisolated",
  "isolated",
  "sending",
  "consuming",
  "borrowing",
  "convenience",
  "required",
  "dynamic",
  "operator",
  "precedencegroup",
  "package",
])
const SWIFT_LIT = new Set(["true", "false", "nil"])

/** Alternation matches the wiki groups in order: ml, block, line, str, attr, num, ident, other. */
const SWIFT_RE = new RegExp(
  [
    String.raw`(?<ml>"""[\s\S]*?""")`,
    String.raw`(?<block>/\*[\s\S]*?\*/)`,
    String.raw`(?<line>//[^\n]*)`,
    String.raw`(?<str>"(?:\\.|[^"\\\n])*")`,
    String.raw`(?<attr>@[A-Za-z_]\w*)`,
    String.raw`(?<num>\b\d[\d_]*(?:\.\d+)?\b)`,
    String.raw`(?<ident>[A-Za-z_]\w*)`,
    String.raw`(?<other>[\s\S])`,
  ].join("|"),
  "g"
)

const GROUP_ORDER = [
  "ml",
  "block",
  "line",
  "str",
  "attr",
  "num",
  "ident",
  "other",
] as const

type Token = { kind: string; text: string }

function tokenize(code: string): Token[] {
  const tokens: Token[] = []
  for (const match of code.matchAll(SWIFT_RE)) {
    const groups = match.groups ?? {}
    const kind =
      GROUP_ORDER.find((name) => groups[name] !== undefined) ?? "other"
    tokens.push({ kind, text: match[0] })
  }
  return tokens
}

/** Tokenized Swift as React nodes; punctuation is grayed, plain identifiers stay uncolored. */
export function highlightSwift(code: string): ReactNode[] {
  const tokens = tokenize(code)
  const out: ReactNode[] = []
  let key = 0
  const span = (className: string, text: string) =>
    createElement("span", { key: key++, className }, text)

  tokens.forEach((token, index) => {
    const { kind, text } = token
    if (kind === "ml" || kind === "str") out.push(span("hl-s", text))
    else if (kind === "block" || kind === "line") out.push(span("hl-c", text))
    else if (kind === "attr") out.push(span("hl-at", text))
    else if (kind === "num") out.push(span("hl-n", text))
    else if (kind === "ident") {
      if (SWIFT_KW.has(text)) out.push(span("hl-kw", text))
      else if (SWIFT_LIT.has(text)) out.push(span("hl-lit", text))
      else if (/^[A-Z]/.test(text)) out.push(span("hl-ty", text))
      else {
        let next = index + 1
        while (next < tokens.length && tokens[next].text.trim() === "")
          next += 1
        if (next < tokens.length && tokens[next].text === "(")
          out.push(span("hl-fn", text))
        else out.push(text)
      }
    } else if (text.trim() === "") out.push(text)
    else out.push(span("hl-p", text))
  })

  return out
}

/** A stable href so the highlight stylesheet is hoisted once and deduped across pages. */
export const HIGHLIGHT_STYLE_HREF = "pfe-highlight"

/**
 * Syntax colors for the tokenizer's spans plus the inline-code chip. The block
 * palette (bare .hl-*) is fixed because the code box is dark in both modes; the
 * inline palette (.ic .hl-*) is muted and switches with the theme. Colors defer
 * to the --pfe-ic-* variables when present, and fall back to the wiki's values.
 */
export const HIGHLIGHT_CSS = `
.hl-kw{color:#db34f2}
.hl-s{color:#ff4245}
.hl-c{color:#30d158}
.hl-ty{color:#00dac3}
.hl-n,.hl-lit{color:#0091ff}
.hl-fn{color:#3cd3fe}
.hl-at{color:#b78a66}
.hl-p{color:#8e8e93}
.markdown code.ic,code.ic{
  border:0;
  border-radius:5px;
  padding:1.5px 5px;
  font-family:var(--font-mono,"SF Mono",Menlo,Monaco,monospace);
  font-size:.86em;
  background:var(--pfe-ic-bg,#f0f0f2);
  color:var(--pfe-ic-fg,#1d1d1f);
  overflow-wrap:anywhere;
}
.dark .markdown code.ic,.dark code.ic{background:var(--pfe-ic-bg,#26262a);color:var(--pfe-ic-fg,#e6e6e6)}
.ic .hl-kw{color:var(--pfe-ic-kw,#9c27b0)}
.ic .hl-s{color:var(--pfe-ic-s,#c41a16)}
.ic .hl-c{color:var(--pfe-ic-c,#177a3a)}
.ic .hl-ty{color:var(--pfe-ic-ty,#0b7a8c)}
.ic .hl-n,.ic .hl-lit{color:var(--pfe-ic-n,#1a56db)}
.ic .hl-fn{color:var(--pfe-ic-fn,#0064b3)}
.ic .hl-at{color:var(--pfe-ic-at,#8a6d3b)}
.ic .hl-p{color:var(--pfe-ic-p,#8a8a8e)}
.dark .ic .hl-kw{color:var(--pfe-ic-kw,#e46ff2)}
.dark .ic .hl-s{color:var(--pfe-ic-s,#ff6b68)}
.dark .ic .hl-c{color:var(--pfe-ic-c,#3ad46a)}
.dark .ic .hl-ty{color:var(--pfe-ic-ty,#3fdccb)}
.dark .ic .hl-n,.dark .ic .hl-lit{color:var(--pfe-ic-n,#4aa3ff)}
.dark .ic .hl-fn{color:var(--pfe-ic-fn,#6cd0ff)}
.dark .ic .hl-at{color:var(--pfe-ic-at,#c79a6b)}
.dark .ic .hl-p{color:var(--pfe-ic-p,#98989d)}
`
