# DeepTranX Crawlab

DeepTranX is a locally branded frontend for Crawlab `v0.6.3`. Crawlab's
backend, API, MongoDB schema and task behavior are kept unchanged.

## Requirements

- Docker Desktop with the Linux engine running
- Docker Compose v2
- PowerShell 5.1 or later
- Node.js `18.20.x` and pnpm `7.33.7` only for host-side frontend work

## First Start

```powershell
.\scripts\init-env.ps1
.\scripts\start-prod.ps1
```

Open `http://localhost:8080`. The initial Crawlab account is `admin/admin`;
change its password immediately after the first successful login.

For frontend hot reload:

```powershell
.\scripts\start-dev.ps1
```

Open `http://localhost:5173`. API requests under `/api` are proxied to the
Crawlab container.

## Common Commands

```powershell
.\scripts\health.ps1
.\scripts\build.ps1
.\scripts\backup.ps1
.\scripts\restore.ps1 -Source .\backup\20260910-120000
.\scripts\stop.ps1
```

See `docs/deployment.md`, `docs/development.md`, `docs/verification.md`,
`docs/upgrade.md` and `docs/troubleshooting.md` for operational details. Exact
upstream versions and local deviations are recorded in `UPSTREAM.md`.
