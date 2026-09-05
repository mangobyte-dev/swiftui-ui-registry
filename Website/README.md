# SwiftUIRegistry website

The registry's website: a Next.js static export built with shadcn/ui. It reads only `content/registry.json`, which `python3 Scripts/generate_site_data.py` (run from the repository root) writes from the validated registry along with the captures under `public/images/`. Never edit that JSON or those images by hand; regenerate them

```sh
python3 Scripts/generate_site_data.py   # from the repository root
cd Website
npm ci
npm run dev          # http://localhost:3000
npm run typecheck
npm run build        # static export under out/
```

Production is Cloudflare Workers static assets (`wrangler.jsonc`, worker `swiftui-registry`): `npm run deploy` builds and uploads `out/` to https://swiftui-registry.mangobytekw.workers.dev after `npx wrangler login`. `.github/workflows/pages.yml` is an alternative that deploys the same export to GitHub Pages with `NEXT_PUBLIC_BASE_PATH` set to the repository name

Pages: `/` (hero, set-up-once steps, item cards), `/items/<name>/` (preview with light and dark captures, install command, usage, source, accessibility contract, details), `/themes/` (presets, the Tune tab export, the token table). Components come from shadcn/ui (`components/ui`); site components live in `components/`
