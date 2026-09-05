// Runs under `node --experimental-strip-types` from test_preset.py: proves the
// website's codec reproduces every pinned vector in both directions and
// refuses what the reference refuses. Prints one JSON line per check.
import { readFileSync } from "node:fs"
import { decodePreset, encodePreset, isPresetCode, presetCodeIn, swiftSource } from "../../Website/lib/preset.ts"

const [vectorsPath] = process.argv.slice(2)
const document = JSON.parse(readFileSync(vectorsPath, "utf8"))
const results: Record<string, unknown>[] = []
for (const vector of document.vectors) {
  results.push({
    name: vector.name,
    encoded: encodePreset(vector.tuning),
    decoded: decodePreset(vector.code),
    swift: swiftSource(vector.tuning),
  })
}
results.push({
  name: "invalid",
  rejected: ["", "a", "b13GkaOXWwIC", "a13GkaOXWwI-", "a" + "z".repeat(22), "aF"].map((code) => decodePreset(code) === null),
  isCode: ["a0", "--preset a13GkaOXWwIC", " a13GkaOXWwIC ", "zz"].map((text) => presetCodeIn(text)),
  bareIsCode: isPresetCode("a13GkaOXWwIC"),
})
process.stdout.write(JSON.stringify(results) + "\n")
