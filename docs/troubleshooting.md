# Troubleshooting

## Docker Is Unavailable

Start Docker Desktop and verify it is using Linux containers:

```powershell
docker info
docker compose version
```

## GitHub Clone Uses A Dead Proxy

Do not change global Git configuration. Bypass it for the individual command:

```powershell
git -c http.proxy= -c https.proxy= clone <repository>
```

## Frontend Cannot Reach The API

Check that `crawlab` is healthy and that `.env` contains:

```text
VITE_API_BASE_URL=/api
VITE_API_PROXY_TARGET=http://crawlab:8080
```

Then inspect:

```powershell
docker compose --env-file .env -f deploy/compose.yml ps
docker compose --env-file .env -f deploy/compose.yml logs crawlab
```

## Patch Installation Fails

The patch path must remain `../patches/crawlab-ui@0.6.2-11.patch` relative to
`frontend/package.json`. Regenerate the lockfile only with pnpm `7.33.7`.

## Host Node Version Warning

The frontend intentionally requires Node `18.20.x`. A different host version
can trigger optional native dependency warnings. Use the development container
for the authoritative result.
