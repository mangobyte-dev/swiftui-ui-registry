"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  BlocksIcon,
  BookOpenIcon,
  BoxesIcon,
  DownloadIcon,
  EyeIcon,
  FileTextIcon,
  HistoryIcon,
  LayersIcon,
  type LucideIcon,
  NotebookTextIcon,
  PaletteIcon,
  PlugIcon,
  ScrollTextIcon,
  SlidersHorizontalIcon,
  TerminalIcon,
  WandSparklesIcon,
} from "lucide-react"

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarRail,
} from "@/components/ui/sidebar"
import { DOCS, DOC_GROUPS, docHref } from "@/lib/docs-nav"
import { KINDS, itemsOfKind, registry } from "@/lib/registry"

// Each installable kind carries an Apple system color, reused for its group icon
// and for the dot on every one of its item rows (wiki style.css PALETTE).
const KIND_META = {
  component: { icon: BoxesIcon, color: "#af52de" },
  block: { icon: LayersIcon, color: "#ff9500" },
  recipe: { icon: ScrollTextIcon, color: "#30b0c7" },
} as const

// Each doc page's tinted line icon, matching the wiki's section-nav rows (its
// BROWSE and REFERENCE groups). Colors cycle the wiki PALETTE for variety.
const DOC_META: Record<string, { icon: LucideIcon; color: string }> = {
  introduction: { icon: BookOpenIcon, color: "#0071e3" },
  installation: { icon: DownloadIcon, color: "#34c759" },
  "design-surface": { icon: SlidersHorizontalIcon, color: "#af52de" },
  cli: { icon: TerminalIcon, color: "#30b0c7" },
  mcp: { icon: PlugIcon, color: "#5856d6" },
  mango: { icon: PaletteIcon, color: "#ff9500" },
  "case-studies": { icon: NotebookTextIcon, color: "#ff375f" },
  architecture: { icon: BlocksIcon, color: "#af52de" },
  "registry-spec": { icon: FileTextIcon, color: "#0071e3" },
  "visual-testing": { icon: EyeIcon, color: "#30b0c7" },
  changelog: { icon: HistoryIcon, color: "#34c759" },
}

// Shared row look: 13.5px text, 7px corners, active row on accent-soft with accent text.
const ITEM_CLASS =
  "rounded-[7px] text-[13.5px] data-active:bg-accent-soft data-active:font-semibold data-active:text-primary"

// Group headings: 11px uppercase gray 600 with wide tracking.
const GROUP_LABEL_CLASS =
  "text-[11px] font-semibold uppercase tracking-[0.05em] text-muted-foreground"

export function SiteSidebar() {
  const pathname = usePathname()
  const isActive = (href: string) =>
    pathname === href || pathname === `${href}/`

  return (
    <Sidebar collapsible="offcanvas">
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              size="lg"
              render={<Link href="/" />}
              isActive={isActive("/")}
            >
              <span
                aria-hidden
                className="flex size-8 items-center justify-center rounded-lg bg-linear-to-br from-indigo-500 to-fuchsia-500 text-white"
              >
                <BoxesIcon className="size-4" />
              </span>
              <span className="flex flex-col leading-tight">
                <span className="font-semibold">{registry.name}</span>
                <span className="text-xs text-muted-foreground">
                  Native-first, copy and own
                </span>
              </span>
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton
              className={ITEM_CLASS}
              render={<Link href="/docs/" />}
              isActive={isActive("/docs")}
            >
              <BookOpenIcon color="#0071e3" />
              Docs
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton
              className={ITEM_CLASS}
              render={<Link href={docHref("design-surface")} />}
              isActive={isActive("/docs/design-surface")}
            >
              <SlidersHorizontalIcon color="#af52de" />
              Design surface
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton
              className={ITEM_CLASS}
              render={<Link href="/themes/" />}
              isActive={isActive("/themes")}
            >
              <PaletteIcon color="#ff375f" />
              Themes
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton
              className={ITEM_CLASS}
              render={<Link href="/create/" />}
              isActive={isActive("/create")}
            >
              <WandSparklesIcon color="#5856d6" />
              Create
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton
              className={ITEM_CLASS}
              render={<Link href={docHref("changelog")} />}
              isActive={isActive("/docs/changelog")}
            >
              <HistoryIcon color="#34c759" />
              Changelog
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        {DOC_GROUPS.map((group) => (
          <SidebarGroup key={group}>
            <SidebarGroupLabel className={GROUP_LABEL_CLASS}>
              {group}
            </SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {DOCS.filter((doc) => doc.group === group).map((doc) => {
                  const meta = DOC_META[doc.slug]
                  return (
                    <SidebarMenuItem key={doc.slug}>
                      <SidebarMenuButton
                        className={ITEM_CLASS}
                        render={<Link href={docHref(doc.slug)} />}
                        isActive={isActive(`/docs/${doc.slug}`)}
                        tooltip={doc.description}
                      >
                        {meta ? <meta.icon color={meta.color} /> : null}
                        {doc.title}
                      </SidebarMenuButton>
                    </SidebarMenuItem>
                  )
                })}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        ))}
        {KINDS.map(({ kind, title }) => {
          const { icon: Icon, color } = KIND_META[kind]
          return (
            <SidebarGroup key={kind}>
              <SidebarGroupLabel className={GROUP_LABEL_CLASS}>
                <Icon className="mr-1.5 size-3.5" color={color} />
                {title}
                <span className="ml-auto text-[11px] tabular-nums">
                  {registry.counts[kind]}
                </span>
              </SidebarGroupLabel>
              <SidebarGroupContent>
                <SidebarMenu>
                  {itemsOfKind(kind).map((item) => {
                    const href = `/items/${item.name}`
                    return (
                      <SidebarMenuItem key={item.name}>
                        <SidebarMenuButton
                          className={ITEM_CLASS}
                          render={<Link href={`${href}/`} />}
                          isActive={isActive(href)}
                          tooltip={item.description}
                        >
                          <span
                            aria-hidden
                            className="size-[7px] shrink-0 rounded-full"
                            style={{ backgroundColor: color }}
                          />
                          {item.name}
                        </SidebarMenuButton>
                      </SidebarMenuItem>
                    )
                  })}
                </SidebarMenu>
              </SidebarGroupContent>
            </SidebarGroup>
          )
        })}
      </SidebarContent>
      <SidebarFooter>
        <p className="px-2 text-xs text-muted-foreground">
          Showcase captures: iPhone 17, iOS 27.
        </p>
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}
