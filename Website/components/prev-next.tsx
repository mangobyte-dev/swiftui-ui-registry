import Link from "next/link"

type NavLink = { href: string; title: string }

/**
 * The two footer cards that walk to the previous and next page. A missing side
 * keeps its column on wide screens so the present card stays aligned.
 */
export function PrevNext({
  previous,
  next,
}: {
  previous?: NavLink | null
  next?: NavLink | null
}) {
  return (
    <nav
      className="mt-14 grid grid-cols-1 gap-4 sm:grid-cols-2"
      aria-label="Pagination"
    >
      {previous ? (
        <Link
          href={previous.href}
          className="group flex flex-col items-start gap-1.5 rounded-[14px] border px-[18px] py-4 text-left transition-[color,border-color,background-color] duration-150 hover:border-primary hover:bg-accent"
        >
          <span className="text-[13px] text-muted-foreground">Previous</span>
          <span className="text-[15px] font-semibold text-foreground group-hover:text-primary">
            {previous.title}
          </span>
        </Link>
      ) : (
        <span className="hidden sm:block" />
      )}
      {next ? (
        <Link
          href={next.href}
          className="group flex flex-col items-end gap-1.5 rounded-[14px] border px-[18px] py-4 text-right transition-[color,border-color,background-color] duration-150 hover:border-primary hover:bg-accent"
        >
          <span className="text-[13px] text-muted-foreground">Next</span>
          <span className="text-[15px] font-semibold text-foreground group-hover:text-primary">
            {next.title}
          </span>
        </Link>
      ) : (
        <span className="hidden sm:block" />
      )}
    </nav>
  )
}
