import type { Metadata } from "next"
import Link from "next/link"
import { Geist, Geist_Mono } from "next/font/google"
import { CodeIcon } from "lucide-react"

import "./globals.css"
import { ThemeProvider } from "@/components/theme-provider"
import { SearchCommand } from "@/components/search-command"
import { SiteSidebar } from "@/components/site-sidebar"
import { ThemeToggle } from "@/components/theme-toggle"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { SidebarInset, SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar"
import { registry } from "@/lib/registry"
import { cn } from "@/lib/utils"

const geist = Geist({ subsets: ["latin"], variable: "--font-sans" })
const fontMono = Geist_Mono({ subsets: ["latin"], variable: "--font-mono" })

export const metadata: Metadata = {
  title: { default: registry.name, template: `%s · ${registry.name}` },
  description:
    "Native-first SwiftUI you copy and own. A shadcn-style registry of source-owned components, blocks, and recipes with a set-up-once theme.",
}

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={cn("antialiased", fontMono.variable, "font-sans", geist.variable)}
    >
      <body>
        <ThemeProvider>
          <SidebarProvider>
            <SiteSidebar />
            <SidebarInset>
              <header className="sticky top-0 z-10 flex h-14 items-center gap-2 border-b bg-background/85 px-4 backdrop-blur">
                <SidebarTrigger />
                <Separator orientation="vertical" className="mx-1 h-5" />
                <SearchCommand />
                <nav className="ml-auto hidden items-center gap-1 sm:flex">
                  <Button variant="ghost" size="sm" render={<Link href="/items/button/" />} nativeButton={false}>
                    Components
                  </Button>
                  <Button variant="ghost" size="sm" render={<Link href="/items/auth-form/" />} nativeButton={false}>
                    Blocks
                  </Button>
                  <Button variant="ghost" size="sm" render={<Link href="/themes/" />} nativeButton={false}>
                    Themes
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    render={<a href={registry.repositoryURL} aria-label="GitHub repository" />}
                    nativeButton={false}
                  >
                    <CodeIcon />
                  </Button>
                </nav>
                <ThemeToggle />
              </header>
              <main className="mx-auto w-full max-w-5xl px-4 py-8 sm:px-8">{children}</main>
              <footer className="mx-auto w-full max-w-5xl px-4 pb-10 text-xs text-muted-foreground sm:px-8">
                <Separator className="mb-4" />
                {registry.name} · MIT · Built with shadcn/ui from <code>Registry/</code> metadata.
              </footer>
            </SidebarInset>
          </SidebarProvider>
        </ThemeProvider>
      </body>
    </html>
  )
}
