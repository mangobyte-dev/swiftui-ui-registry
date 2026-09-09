import { readFileSync } from "node:fs"
import path from "node:path"

import type { DocPage } from "@/lib/docs-nav"

/**
 * Reads a doc's markdown at build time and drops its first-level heading,
 * which the page renders as its title from the nav entry.
 */
export function readDoc(doc: DocPage): string {
  const text = readFileSync(path.join(process.cwd(), doc.file), "utf8")
  const lines = text.split("\n")
  const first = lines.findIndex((line) => line.trim() !== "")
  if (first >= 0 && lines[first].startsWith("# ")) {
    lines.splice(first, 1)
  }
  return lines.join("\n").trim() + "\n"
}
