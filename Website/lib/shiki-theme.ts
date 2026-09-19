import type { ThemeRegistrationRaw } from "shiki"

/**
 * The Point-Free Evolution code palette as a single shiki theme.
 *
 * The wiki's code box is dark in both color modes, so one fixed theme drives
 * light and dark alike. Every color below is the wiki's block palette: keywords
 * magenta, strings red, comments green, numbers and literals blue, types mint,
 * function calls cyan, attributes brown, punctuation grayed so structure recedes.
 */
const FG = "#dfdfe0"
const BG = "#1f1f24"
const KEYWORD = "#db34f2"
const STRING = "#ff4245"
const COMMENT = "#30d158"
const NUMBER = "#0091ff"
const TYPE = "#00dac3"
const FUNCTION = "#3cd3fe"
const ATTRIBUTE = "#b78a66"
const PUNCTUATION = "#8e8e93"

/**
 * Scopes are drawn from the TextMate grammars shiki emits for swift, json, bash,
 * typescript, and plain text, mapped onto the wiki palette.
 */
export const pfeTheme: ThemeRegistrationRaw = {
  name: "pfe",
  type: "dark",
  colors: {
    "editor.background": BG,
    "editor.foreground": FG,
  },
  settings: [
    { settings: { background: BG, foreground: FG } },
    {
      scope: [
        "keyword",
        "keyword.control",
        "keyword.operator.new",
        "keyword.operator.expression",
        "keyword.operator.logical",
        "keyword.other",
        "storage",
        "storage.type",
        "storage.modifier",
        "variable.language.this",
        "variable.language.self",
        "constant.language.boolean.json",
      ],
      settings: { foreground: KEYWORD },
    },
    {
      scope: [
        "string",
        "string.quoted",
        "string.template",
        "string.interpolated",
        "string.regexp",
        "punctuation.definition.string",
        "meta.string-contents",
      ],
      settings: { foreground: STRING },
    },
    {
      scope: ["comment", "punctuation.definition.comment", "string.comment"],
      settings: { foreground: COMMENT },
    },
    {
      scope: [
        "constant.numeric",
        "constant.language",
        "constant.other",
        "constant.character",
        "support.constant",
        "keyword.other.unit",
      ],
      settings: { foreground: NUMBER },
    },
    {
      scope: [
        "entity.name.type",
        "entity.name.class",
        "entity.name.struct",
        "entity.name.enum",
        "entity.name.protocol",
        "entity.other.inherited-class",
        "support.type",
        "support.class",
        "storage.type.built-in",
      ],
      settings: { foreground: TYPE },
    },
    {
      scope: [
        "entity.name.function",
        "meta.function-call",
        "meta.function-call.method",
        "support.function",
        "variable.function",
      ],
      settings: { foreground: FUNCTION },
    },
    {
      scope: [
        "storage.type.attribute",
        "meta.attribute",
        "punctuation.definition.attribute",
        "entity.other.attribute-name",
        "support.type.property-name.json",
      ],
      settings: { foreground: ATTRIBUTE },
    },
    {
      scope: [
        "punctuation",
        "punctuation.separator",
        "punctuation.terminator",
        "punctuation.definition.parameters",
        "punctuation.section",
        "keyword.operator",
        "meta.brace",
        "meta.delimiter",
      ],
      settings: { foreground: PUNCTUATION },
    },
  ],
}
