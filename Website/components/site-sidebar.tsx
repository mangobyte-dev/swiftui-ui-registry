"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { BookOpenIcon, BoxesIcon, HistoryIcon, LayersIcon, PaletteIcon, ScrollTextIcon, SlidersHorizontalIcon, WandSparklesIcon } from "lucide-react"

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

const KIND_ICONS = {
  component: BoxesIcon,
  block: LayersIcon,
  recipe: ScrollTextIcon,
} as const

export function SiteSidebar() {
  const pathname = usePathname()
  const isActive = (href: string) => pathname === href || pathname === `${href}/`

  return (
    <Sidebar collapsible="offcanvas">
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" render={<Link href="/" />} isActive={isActive("/")}>
              <span
                aria-hidden
                className="flex size-8 items-center justify-center rounded-lg bg-linear-to-br from-indigo-500 to-fuchsia-500 text-white"
              >
                <BoxesIcon className="size-4" />
              </span>
              <span className="flex flex-col leading-tight">
                <span className="font-semibold">{registry.name}</span>
                <span className="text-xs text-muted-foreground">Native-first, copy and own</span>
              </span>
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton render={<Link href="/docs/" />} isActive={isActive("/docs")}>
              <BookOpenIcon />
              Docs
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton
              render={<Link href={docHref("design-surface")} />}
              isActive={isActive("/docs/design-surface")}
            >
              <SlidersHorizontalIcon />
              Design surface
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton render={<Link href="/themes/" />} isActive={isActive("/themes")}>
              <PaletteIcon />
              Themes
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton render={<Link href="/create/" />} isActive={isActive("/create")}>
              <WandSparklesIcon />
              Create
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton render={<Link href={docHref("changelog")} />} isActive={isActive("/docs/changelog")}>
              <HistoryIcon />
              Changelog
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        {DOC_GROUPS.map((group) => (
          <SidebarGroup key={group}>
            <SidebarGroupLabel>
              <BookOpenIcon className="mr-1.5 size-3.5" />
              {group}
            </SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {DOCS.filter((doc) => doc.group === group).map((doc) => (
                  <SidebarMenuItem key={doc.slug}>
                    <SidebarMenuButton
                      render={<Link href={docHref(doc.slug)} />}
                      isActive={isActive(`/docs/${doc.slug}`)}
                      tooltip={doc.description}
                    >
                      {doc.title}
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        ))}
        {KINDS.map(({ kind, title }) => {
          const Icon = KIND_ICONS[kind]
          return (
            <SidebarGroup key={kind}>
              <SidebarGroupLabel>
                <Icon className="mr-1.5 size-3.5" />
                {title}
                <span className="ml-auto text-xs tabular-nums">{registry.counts[kind]}</span>
              </SidebarGroupLabel>
              <SidebarGroupContent>
                <SidebarMenu>
                  {itemsOfKind(kind).map((item) => {
                    const href = `/items/${item.name}`
                    return (
                      <SidebarMenuItem key={item.name}>
                        <SidebarMenuButton
                          render={<Link href={`${href}/`} />}
                          isActive={isActive(href)}
                          tooltip={item.description}
                        >
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
          Captures from the Showcase on iPhone 17, iOS 27.
        </p>
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}
