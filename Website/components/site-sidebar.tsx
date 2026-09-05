"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { BoxesIcon, LayersIcon, PaletteIcon, ScrollTextIcon } from "lucide-react"

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
            <SidebarMenuButton render={<Link href="/themes/" />} isActive={isActive("/themes")}>
              <PaletteIcon />
              Themes
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
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
