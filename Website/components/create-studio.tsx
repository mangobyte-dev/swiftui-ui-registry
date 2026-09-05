"use client"

import * as React from "react"
import { useSearchParams } from "next/navigation"
import { useTheme } from "next-themes"
import { DicesIcon, Link2Icon, MoonIcon, RotateCcwIcon, SunIcon } from "lucide-react"

import { CopyButton } from "@/components/copy-button"
import { PresetBoard } from "@/components/preset-board"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Slider } from "@/components/ui/slider"
import { Switch } from "@/components/ui/switch"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"
import {
  ACCENTS,
  ACCENT_TITLES,
  DEFAULT_TUNING,
  IOS_COLORS,
  NUMERIC_FIELDS,
  PRESETS,
  applyCommand,
  decodePreset,
  encodePreset,
  maximum,
  presetCodeIn,
  presetMatching,
  randomTuning,
  swiftSource,
  type Accent,
  type NumericField,
  type PresetTuning,
} from "@/lib/preset"
import { asset, registry } from "@/lib/registry"
import { cn } from "@/lib/utils"

type Appearance = "light" | "dark"

const SHOWCASE_DEFAULT: PresetTuning = { ...DEFAULT_TUNING, accent: "indigo" }

function initialTuning(requested: string | null): PresetTuning {
  if (requested === "random") return randomTuning()
  return (requested && decodePreset(requested)) || SHOWCASE_DEFAULT
}

/** Compose a RegistryTheme from the Showcase's tuning knobs and share it as a preset code. */
export function CreateStudio() {
  const searchParams = useSearchParams()
  const [tuning, setTuning] = React.useState<PresetTuning>(() => initialTuning(searchParams.get("preset")))
  const { resolvedTheme } = useTheme()
  const [chosenAppearance, setChosenAppearance] = React.useState<Appearance | null>(null)
  const appearance: Appearance = chosenAppearance ?? (resolvedTheme === "dark" ? "dark" : "light")
  const code = encodePreset(tuning)

  React.useEffect(() => {
    try {
      window.history.replaceState(null, "", `?preset=${code}`)
    } catch {
      // A sandboxed preview cannot rewrite the address; the code stays visible on the page.
    }
  }, [code])

  return (
    <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_336px]">
      <div className="flex min-w-0 flex-col gap-4">
        <PreviewPanel tuning={tuning} code={code} appearance={appearance} onAppearance={setChosenAppearance} />
        <CodeBar code={code} onTuning={setTuning} />
      </div>
      <Customizer tuning={tuning} appearance={appearance} onTuning={setTuning} />
    </div>
  )
}

function PreviewPanel({
  tuning,
  code,
  appearance,
  onAppearance,
}: {
  tuning: PresetTuning
  code: string
  appearance: Appearance
  onAppearance: (appearance: Appearance) => void
}) {
  const matched = presetMatching(tuning)
  const capture = matched ? registry.presets.find((preset) => preset.slug === matched.slug)?.screenshots[appearance] : null
  const swift = swiftSource(tuning)

  return (
    <Tabs defaultValue="preview" className="gap-0 overflow-hidden rounded-xl border">
      <div className="flex min-w-0 items-center justify-between gap-2 border-b bg-muted/50 px-2 py-1.5">
        <TabsList>
          <TabsTrigger value="preview">Preview</TabsTrigger>
          <TabsTrigger value="swift">Swift</TabsTrigger>
          <TabsTrigger value="apply">Apply</TabsTrigger>
        </TabsList>
        <ToggleGroup
          value={[appearance]}
          onValueChange={(value: string[]) => value.length && onAppearance(value[0] as Appearance)}
          aria-label="Preview appearance"
          variant="outline"
          size="sm"
        >
          <ToggleGroupItem value="light" aria-label="Light">
            <SunIcon />
          </ToggleGroupItem>
          <ToggleGroupItem value="dark" aria-label="Dark">
            <MoonIcon />
          </ToggleGroupItem>
        </ToggleGroup>
      </div>
      <TabsContent
        value="preview"
        className={cn("flex flex-col items-center gap-4 p-3 sm:p-8", appearance === "dark" ? "bg-[#0b0b0d]" : "bg-[#f4f4f6]")}
      >
        <PresetBoard tuning={tuning} appearance={appearance} />
        <p className={cn("max-w-[52ch] text-center text-xs", appearance === "dark" ? "text-neutral-400" : "text-neutral-500")}>
          A token board drawn in CSS from the decoded values, with the system colors as they resolve on iOS 27.
          The Showcase renders the real SwiftUI: open Tune and import the code, or run{" "}
          <code>capture_previews.py --preset {code}</code>.
        </p>
        {capture ? (
          <figure className="flex w-full max-w-[420px] flex-col gap-2">
            {/* The capture is the real Showcase on iPhone 17; next/image is not needed for a static export. */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={asset(capture)} alt={`${matched?.name} preset captured on iPhone 17, ${appearance}`} className="w-full rounded-xl border shadow-lg" />
            <figcaption className={cn("text-center text-xs", appearance === "dark" ? "text-neutral-400" : "text-neutral-500")}>
              This code is the {matched?.name} preset; above is its capture from the Showcase.
            </figcaption>
          </figure>
        ) : null}
      </TabsContent>
      <TabsContent value="swift" className="relative">
        <div className="absolute top-2 right-2">
          <CopyButton text={swift} label="Copy Swift" />
        </div>
        <pre className="max-h-[560px] overflow-auto p-4 pr-14 font-mono text-[12.5px] leading-relaxed sm:text-[13px]">{swift}</pre>
      </TabsContent>
      <TabsContent value="apply" className="flex flex-col gap-4 p-4">
        <ApplyStep title="From a clone of the registry" detail="Writes RegistryTheme+App.swift next to your installed items, declaring RegistryTheme.app.">
          <Command text={applyCommand(code)} />
        </ApplyStep>
        <ApplyStep title="Then once at your scene root" detail="Every registry item and every tinted native control below inherits it.">
          <Command text={"ContentView()\n    .registryTheme(.app)"} />
        </ApplyStep>
        <ApplyStep title="On a device" detail="In the Showcase, open Tune, choose Import, and paste the code; or launch the app with the argument below.">
          <Command text={`-preset ${code}`} />
        </ApplyStep>
        <ApplyStep title="For an agent" detail="The MCP server's describe_preset and apply_preset tools, or the CLI, decode the same code.">
          <Command text={`python3 Scripts/preset.py decode ${code}`} />
        </ApplyStep>
      </TabsContent>
    </Tabs>
  )
}

function ApplyStep({ title, detail, children }: { title: string; detail: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-2">
      <div className="flex flex-col gap-0.5">
        <h3 className="text-sm font-semibold">{title}</h3>
        <p className="text-xs text-muted-foreground">{detail}</p>
      </div>
      {children}
    </div>
  )
}

function Command({ text }: { text: string }) {
  return (
    <div className="relative rounded-lg border bg-card">
      <div className="absolute top-1.5 right-1.5">
        <CopyButton text={text} />
      </div>
      <pre className="overflow-x-auto p-3 pr-12 font-mono text-[12.5px] leading-relaxed">{text}</pre>
    </div>
  )
}

function CodeBar({ code, onTuning }: { code: string; onTuning: (tuning: PresetTuning) => void }) {
  const [linkCopied, setLinkCopied] = React.useState(false)

  async function copyLink() {
    try {
      await navigator.clipboard.writeText(`${window.location.origin}${window.location.pathname}?preset=${code}`)
      setLinkCopied(true)
      window.setTimeout(() => setLinkCopied(false), 1400)
    } catch {
      // The address bar already carries the code.
    }
  }

  return (
    <div className="flex flex-wrap items-center gap-2 rounded-xl border bg-card p-2">
      <code className="min-w-0 flex-1 truncate px-2 font-mono text-sm" title={`--preset ${code}`}>
        --preset {code}
      </code>
      <CopyButton text={`--preset ${code}`} label="Copy preset" />
      <Button variant="outline" size="sm" onClick={copyLink}>
        <Link2Icon data-icon="inline-start" />
        {linkCopied ? "Copied" : "Copy link"}
      </Button>
      <OpenPresetDialog onOpen={onTuning} />
      <Button variant="outline" size="sm" onClick={() => onTuning(randomTuning())}>
        <DicesIcon data-icon="inline-start" />
        Random
      </Button>
      <Button variant="ghost" size="sm" onClick={() => onTuning(SHOWCASE_DEFAULT)}>
        <RotateCcwIcon data-icon="inline-start" />
        Reset
      </Button>
    </div>
  )
}

function OpenPresetDialog({ onOpen }: { onOpen: (tuning: PresetTuning) => void }) {
  const [open, setOpen] = React.useState(false)
  const [input, setInput] = React.useState("")
  const code = presetCodeIn(input)
  const decoded = code ? decodePreset(code) : null
  const isInvalid = input.trim().length > 0 && decoded === null

  function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!decoded) return
    onOpen(decoded)
    setOpen(false)
    setInput("")
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger render={<Button variant="outline" size="sm" />}>Open</DialogTrigger>
      <DialogContent>
        <form onSubmit={submit} className="flex flex-col gap-4">
          <DialogHeader>
            <DialogTitle>Open a preset</DialogTitle>
            <DialogDescription>Paste a code from the Showcase, a teammate, or a link, with or without its --preset flag.</DialogDescription>
          </DialogHeader>
          <div className="flex flex-col gap-2">
            <Label htmlFor="preset-code">Preset code</Label>
            <Input
              id="preset-code"
              value={input}
              onChange={(event) => setInput(event.target.value)}
              placeholder="a13GkaOXWwIF or --preset a13GkaOXWwIF"
              autoCapitalize="none"
              autoCorrect="off"
              spellCheck={false}
              aria-invalid={isInvalid}
            />
            {isInvalid ? <p className="text-xs text-destructive">That is not a preset code.</p> : null}
          </div>
          <DialogFooter>
            <DialogClose render={<Button variant="outline" type="button" />}>Cancel</DialogClose>
            <Button type="submit" disabled={!decoded}>
              Open
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

function Customizer({
  tuning,
  appearance,
  onTuning,
}: {
  tuning: PresetTuning
  appearance: Appearance
  onTuning: (tuning: PresetTuning) => void
}) {
  const update = (changes: Partial<PresetTuning>) => onTuning({ ...tuning, ...changes })
  const matched = presetMatching(tuning)
  const groups: { title: string; keys: NumericField["key"][] }[] = [
    { title: "Surface", keys: ["surfaceOpacity", "borderOpacity", "borderWidth", "emphasizedBorderWidth"] },
    { title: "Radius", keys: ["compactRadius", "controlRadius", "cardRadius"] },
    { title: "Spacing", keys: ["compactSpacing", "standardSpacing", "sectionSpacing", "controlHorizontalPadding"] },
    { title: "State", keys: ["disabledOpacity"] },
  ]

  return (
    <Card className="h-fit lg:sticky lg:top-20">
      <CardHeader>
        <CardTitle>Customize</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col gap-6">
        <Fieldset title="Presets">
          <div className="flex flex-wrap gap-1.5">
            {PRESETS.map((preset) => (
              <Button
                key={preset.slug}
                size="sm"
                variant={matched?.slug === preset.slug ? "default" : "outline"}
                aria-pressed={matched?.slug === preset.slug}
                onClick={() => onTuning({ ...preset.tuning })}
              >
                {preset.name}
              </Button>
            ))}
          </div>
        </Fieldset>

        <Fieldset title="Accent">
          <div className="grid grid-cols-7 gap-2" role="radiogroup" aria-label="Accent">
            {ACCENTS.filter((accent): accent is Exclude<Accent, "custom"> => accent !== "custom").map((accent) => (
              <button
                key={accent}
                type="button"
                role="radio"
                aria-checked={tuning.accent === accent}
                aria-label={ACCENT_TITLES[accent]}
                title={ACCENT_TITLES[accent]}
                onClick={() => update({ accent })}
                className={cn(
                  "flex size-8 items-center justify-center rounded-full border-2 border-transparent outline-none transition-transform focus-visible:ring-3 focus-visible:ring-ring/50",
                  tuning.accent === accent && "border-foreground scale-110"
                )}
                style={{ background: IOS_COLORS[accent][appearance] }}
              >
                {accent === "system" ? <span className="text-[10px] font-bold text-white">iOS</span> : null}
              </button>
            ))}
          </div>
          <ColorRow
            id="custom-accent"
            label="Custom accent"
            value={tuning.customAccent ?? "#5957D6"}
            selected={tuning.accent === "custom"}
            onChange={(value) => update({ accent: "custom", customAccent: value, customAccentDark: tuning.customAccentDark ?? null })}
          />
          <SwitchRow
            id="separate-dark"
            label="Separate dark accent"
            checked={tuning.accent === "custom" && Boolean(tuning.customAccentDark)}
            onChange={(checked) =>
              update({
                accent: "custom",
                customAccent: tuning.customAccent ?? "#5957D6",
                customAccentDark: checked ? (tuning.customAccentDark ?? tuning.customAccent ?? "#5957D6") : null,
              })
            }
          />
          {tuning.accent === "custom" && tuning.customAccentDark ? (
            <ColorRow
              id="custom-accent-dark"
              label="Custom accent in dark"
              value={tuning.customAccentDark}
              selected
              onChange={(value) => update({ customAccentDark: value })}
            />
          ) : null}
          <SwitchRow
            id="dark-label"
            label="Dark label on accent"
            checked={tuning.darkLabelOnAccent}
            disabled={tuning.accent === "ink"}
            onChange={(checked) => update({ darkLabelOnAccent: checked })}
          />
        </Fieldset>

        {groups.map((group) => (
          <Fieldset key={group.title} title={group.title}>
            {NUMERIC_FIELDS.filter((field) => group.keys.includes(field.key)).map((field) => (
              <SliderRow key={field.key} field={field} value={tuning[field.key]} onChange={(value) => update({ [field.key]: value })} />
            ))}
          </Fieldset>
        ))}
      </CardContent>
    </Card>
  )
}

function Fieldset({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <fieldset className="flex flex-col gap-3">
      <legend className="mb-2 text-xs font-semibold tracking-widest text-muted-foreground uppercase">{title}</legend>
      {children}
    </fieldset>
  )
}

function SliderRow({ field, value, onChange }: { field: NumericField; value: number; onChange: (value: number) => void }) {
  return (
    <div className="flex flex-col gap-1.5">
      <div className="flex items-center justify-between text-sm">
        <Label htmlFor={field.key}>{field.label}</Label>
        <span className="font-mono text-xs text-muted-foreground tabular-nums">{value.toFixed(field.decimals)}</span>
      </div>
      <Slider
        id={field.key}
        aria-label={field.label}
        min={field.minimum}
        max={maximum(field)}
        step={field.step}
        value={[value]}
        onValueChange={(next) => onChange(Array.isArray(next) ? next[0] : next)}
      />
    </div>
  )
}

function SwitchRow({
  id,
  label,
  checked,
  disabled,
  onChange,
}: {
  id: string
  label: string
  checked: boolean
  disabled?: boolean
  onChange: (checked: boolean) => void
}) {
  return (
    <div className="flex items-center justify-between gap-3">
      <Label htmlFor={id} className={cn(disabled && "opacity-50")}>
        {label}
      </Label>
      <Switch id={id} checked={checked} disabled={disabled} onCheckedChange={(next) => onChange(next)} />
    </div>
  )
}

function ColorRow({
  id,
  label,
  value,
  selected,
  onChange,
}: {
  id: string
  label: string
  value: string
  selected: boolean
  onChange: (value: string) => void
}) {
  return (
    <div className="flex items-center justify-between gap-3">
      <Label htmlFor={id}>{label}</Label>
      <span className="flex items-center gap-2">
        <code className="font-mono text-xs text-muted-foreground">{selected ? value.toUpperCase() : ""}</code>
        <input
          id={id}
          type="color"
          value={value}
          onChange={(event) => onChange(event.target.value.toUpperCase())}
          className={cn("size-8 cursor-pointer rounded-full border-2 border-transparent bg-transparent p-0", selected && "border-foreground")}
        />
      </span>
    </div>
  )
}
