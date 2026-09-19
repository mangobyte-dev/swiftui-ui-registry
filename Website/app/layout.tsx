import type { Metadata } from "next"
import Link from "next/link"
import { CodeIcon } from "lucide-react"

import "./globals.css"
import { ThemeProvider } from "@/components/theme-provider"
import { SearchCommand } from "@/components/search-command"
import { SiteSidebar } from "@/components/site-sidebar"
import { ThemeToggle } from "@/components/theme-toggle"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import {
  SidebarInset,
  SidebarProvider,
  SidebarTrigger,
} from "@/components/ui/sidebar"
import { registry } from "@/lib/registry"

export const metadata: Metadata = {
  title: { default: registry.name, template: `%s · ${registry.name}` },
  description:
    "Native-first SwiftUI, copy and own. Shadcn-style registry: source-owned components, blocks, recipes, set-up-once theme.",
}

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" suppressHydrationWarning className="antialiased">
      <body>
        <ThemeProvider>
          <SidebarProvider>
            <SiteSidebar />
            <SidebarInset className="min-w-0">
              <header
                className="sticky top-0 z-10 flex h-15 min-w-0 items-center gap-3 border-b bg-topbar px-4 sm:px-6"
                style={{
                  backdropFilter: "saturate(180%) blur(20px)",
                  WebkitBackdropFilter: "saturate(180%) blur(20px)",
                }}
              >
                <SidebarTrigger className="h-[34px] w-auto rounded-[8px] border border-border px-3 text-[13px] font-normal md:hidden">
                  Menu
                </SidebarTrigger>
                <Link
                  href="/"
                  className="text-[19px] font-semibold tracking-tight md:hidden"
                >
                  {registry.name}
                </Link>
                <div className="mx-auto w-full max-w-[600px]">
                  <SearchCommand />
                </div>
                <nav className="hidden items-center gap-1 sm:flex">
                  <Button
                    variant="ghost"
                    size="sm"
                    render={<Link href="/docs/" />}
                    nativeButton={false}
                  >
                    Docs
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    render={<Link href="/items/button/" />}
                    nativeButton={false}
                  >
                    Components
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    render={<Link href="/items/auth-form/" />}
                    nativeButton={false}
                  >
                    Blocks
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    render={<Link href="/themes/" />}
                    nativeButton={false}
                  >
                    Themes
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    render={<Link href="/create/" />}
                    nativeButton={false}
                  >
                    Create
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    render={
                      <a
                        href={registry.repositoryURL}
                        aria-label="GitHub repository"
                      />
                    }
                    nativeButton={false}
                  >
                    <CodeIcon />
                  </Button>
                </nav>
                <ThemeToggle />
              </header>
              <main className="mx-auto w-full max-w-5xl min-w-0 px-4 py-6 sm:px-8 sm:py-8">
                {children}
              </main>
              <footer className="mx-auto w-full max-w-5xl px-4 pb-10 text-xs text-muted-foreground sm:px-8">
                <Separator className="mb-4" />
                {registry.name} · MIT · Built with shadcn/ui from{" "}
                <code>Registry/</code> metadata.
              </footer>
            </SidebarInset>
          </SidebarProvider>
        </ThemeProvider>
      </body>
    </html>
  )
}
