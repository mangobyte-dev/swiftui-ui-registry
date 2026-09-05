"use client"

import { accentColor, onAccentColor, type PresetTuning } from "@/lib/preset"

type Appearance = "light" | "dark"

/**
 * The tokens a code carries, drawn in CSS: the same composition the Showcase's
 * theme preview renders, as plain shapes. It is a token board, not a SwiftUI
 * render; the Showcase and `capture_previews.py --preset` draw the real thing.
 */
export function PresetBoard({ tuning, appearance }: { tuning: PresetTuning; appearance: Appearance }) {
  const ink = appearance === "dark" ? "255, 255, 255" : "0, 0, 0"
  const accent = accentColor(tuning, appearance)
  const onAccent = onAccentColor(tuning, appearance)
  const negative = appearance === "dark" ? "#FF4245" : "#FF383C"
  const positive = appearance === "dark" ? "#30D158" : "#34C759"
  const surface = `rgba(${ink}, ${tuning.surfaceOpacity})`
  const border = `${tuning.borderWidth}px solid rgba(${ink}, ${tuning.borderOpacity})`
  const control = { borderRadius: tuning.controlRadius, padding: `10px ${tuning.controlHorizontalPadding}px` }
  const pill = "inline-flex min-h-[44px] items-center text-[15px] font-semibold leading-none"
  const badge = { borderRadius: tuning.compactRadius, padding: "3px 8px" }

  return (
    <div
      className="flex w-full max-w-[420px] flex-col font-sans text-[15px] antialiased"
      style={{
        background: appearance === "dark" ? "#000000" : "#FFFFFF",
        color: `rgb(${ink})`,
        gap: tuning.sectionSpacing,
        padding: tuning.standardSpacing,
        borderRadius: tuning.cardRadius,
      }}
    >
      <div className="flex flex-wrap" style={{ gap: tuning.compactSpacing }}>
        <span className={pill} style={{ ...control, background: accent, color: onAccent }}>Primary</span>
        <span className={pill} style={{ ...control, background: surface }}>Secondary</span>
        <span className={pill} style={{ ...control, border }}>Outline</span>
        <span className={pill} style={{ ...control, color: accent }}>Ghost</span>
        <span className={pill} style={{ ...control, background: negative, color: "#FFFFFF" }}>Delete</span>
        <span className={pill} style={{ ...control, background: accent, color: onAccent, opacity: tuning.disabledOpacity }}>
          Disabled
        </span>
      </div>

      <div className="flex flex-wrap text-[12px] font-semibold" style={{ gap: tuning.compactSpacing }}>
        <span style={{ ...badge, background: accent, color: onAccent }}>New</span>
        <span style={{ ...badge, background: surface }}>Draft</span>
        <span style={{ ...badge, background: positive, color: "#FFFFFF" }}>Paid</span>
        <span style={{ ...badge, background: negative, color: "#FFFFFF" }}>Overdue</span>
      </div>

      <div className="flex flex-col" style={{ gap: tuning.compactSpacing }}>
        <div
          className="flex min-h-[44px] items-center"
          style={{ ...control, background: surface, border, color: `rgba(${ink}, 0.45)` }}
        >
          Email
        </div>
        <div
          className="flex min-h-[44px] items-center"
          style={{
            ...control,
            background: surface,
            border: `${tuning.emphasizedBorderWidth}px solid ${accent}`,
          }}
        >
          mo@example.com
        </div>
      </div>

      <div
        className="flex flex-col"
        style={{ background: surface, border, borderRadius: tuning.cardRadius, padding: tuning.standardSpacing, gap: tuning.compactSpacing }}
      >
        <div className="flex items-center gap-3">
          <span
            className="flex size-[22px] shrink-0 items-center justify-center text-[14px] font-bold"
            style={{ background: accent, color: onAccent, borderRadius: tuning.compactRadius }}
          >
            ✓
          </span>
          Accept terms
        </div>
        <div className="flex items-center justify-between gap-3">
          Transaction alerts
          <span className="relative block h-[31px] w-[51px] rounded-full" style={{ background: accent }}>
            <span className="absolute top-[2px] right-[2px] size-[27px] rounded-full bg-white shadow-sm" />
          </span>
        </div>
        <div className="flex flex-col gap-1.5 text-[13px]">
          Uploading
          <span className="block h-1.5 w-full overflow-hidden rounded-full" style={{ background: `rgba(${ink}, 0.12)` }}>
            <span className="block h-full w-[68%] rounded-full" style={{ background: accent }} />
          </span>
        </div>
      </div>
    </div>
  )
}
