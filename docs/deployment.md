# Deployment

## Production

1. Start Docker Desktop and select the Linux container engine.
2. Run `.\scripts\init-env.ps1`.
3. Review `.env`, especially ports, node name and runner count.
4. Run `.\scripts\start-prod.ps1`.
5. Run `.\scripts\health.ps1`.
6. Sign in at `http://localhost:8080` with `admin/admin`, then change the
   password immediately.

The production image is `deeptranx/crawlab:0.1.0-crawlab0.6.3`. It builds the
frontend with Node `18.20.8` and pnpm `7.33.7`, then copies only the generated
files to `/app/dist` in the fixed Crawlab image.

MongoDB is reachable only on the Compose network. The named volumes are:

- `deeptranx_mongo-data`: MongoDB `/data/db`
- `deeptranx_crawlab-data`: Crawlab `/root/.crawlab`
- `deeptranx_bhol-exports`: BHOL JSONL `/data/exports`

Do not use `docker compose down --volumes` unless permanent data deletion is
intended.

## Development

Run `.\scripts\start-dev.ps1`. This starts:

- MongoDB on the internal network
- the official fixed Crawlab image on port `8080`
- Vite with source mounts and hot reload on port `5173`

The browser should use port `5173` during frontend work. Vite forwards `/api`
to `http://crawlab:8080`.

## Backup And Restore

Create a consistent backup:

```powershell
.\scripts\backup.ps1
```

The script temporarily stops Crawlab, dumps MongoDB, archives
`/root/.crawlab` and `/data/exports`, then starts Crawlab again. Files are
written below `backup/`.

Restore:

```powershell
.\scripts\restore.ps1 -Source .\backup\20260910-120000
```

Restore replaces current MongoDB and Crawlab data. Perform a restore drill
before relying on backups operationally.
