# Frontend Development

## Local Workflow

The supported toolchain is Node.js `18.20.x` with pnpm `7.33.7`.

```powershell
Set-Location frontend
corepack enable
corepack prepare pnpm@7.33.7 --activate
pnpm install --frozen-lockfile
pnpm typecheck
pnpm build
```

The Docker development workflow is preferred because it enforces Node 18.20:

```powershell
.\scripts\start-dev.ps1
```

## Ownership Boundaries

- Change branding and global visual rules in `frontend/src/brand.css`.
- Replace image assets in `frontend/public/brand/`.
- Keep API calls, routes, permission checks, stores and business forms from
  `crawlab-ui` unchanged.
- Use `patches/crawlab-ui@0.6.2-11.patch` only for unavoidable hard-coded
  upstream content.
- Never edit `frontend/node_modules`.

When a change needs substantial new pages or menus, vendor the exact
`crawlab-ui` source commit into a pnpm workspace instead of growing the patch
indefinitely.

## Offline Check

After `pnpm build`, inspect `frontend/dist` and the browser Network panel.
Application assets must originate from the current host. Crawlab API traffic
under `/api` is expected; analytics, CDN fonts, GitHub widgets and external
documentation requests are not.
