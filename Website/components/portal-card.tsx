import Link from "next/link"
import type { LucideIcon } from "lucide-react"

type PortalCardProps = {
  href: string
  title: string
  description: string
  icon: LucideIcon
  color: string
}

/**
 * A wiki-style portal card: a tinted line icon beside a title and description,
 * lifting on hover. The icon inherits `color`; the rest follows the tokens.
 */
export function PortalCard({
  href,
  title,
  description,
  icon: Icon,
  color,
}: PortalCardProps) {
  return (
    <Link
      href={href}
      className="group flex items-start gap-[14px] rounded-[14px] border bg-card p-[18px] transition-[color,border-color,box-shadow,transform] duration-150 hover:-translate-y-px hover:border-primary hover:shadow-[0_8px_24px_rgba(0,0,0,0.1)]"
    >
      <Icon
        aria-hidden
        className="mt-px size-7 shrink-0"
        strokeWidth={1.7}
        style={{ color }}
      />
      <span className="min-w-0">
        <span className="block text-[16px] font-semibold text-foreground group-hover:text-primary">
          {title}
        </span>
        <span className="mt-1 block text-[13.5px] leading-[1.45] text-muted-foreground">
          {description}
        </span>
      </span>
    </Link>
  )
}
