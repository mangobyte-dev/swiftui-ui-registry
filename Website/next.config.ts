import type { NextConfig } from "next"

// Static export for GitHub Pages. `NEXT_PUBLIC_BASE_PATH` is set by the Pages
// workflow to the repository name; local `next dev` and `next build` run at "/".
const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? ""

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  trailingSlash: true,
  images: { unoptimized: true },
}

export default nextConfig
