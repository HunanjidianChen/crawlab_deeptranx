# Upstream Baseline

Baseline verified on 2026-09-10.

| Component | Version | Immutable reference |
| --- | --- | --- |
| Crawlab source | `v0.6.3` | `2dbc7373eb33f2ecd2c13e6a408c90aa72574ca7` |
| Crawlab runtime image | `0.6.3` | `sha256:9dbe97240ba2670ce49fd1be5d557b59653e602d8fa29a71c9e05b26c557193b` |
| MongoDB image | `4.2` | `sha256:699d652ed67423d689258bad7b316cf005dfbb82b334118ec306f049042f3717` |
| crawlab-ui package | `0.6.2-11` | `c6904bea66ffa84f31f4556ee2f55d2798cb775c` |
| Node.js build image | `18.20.8-bookworm-slim` | tag pinned to the required Node 18.20 line |
| pnpm | `7.33.7` | fixed by `packageManager` and Docker build |

## Local Changes

- `frontend/` is a thin DeepTranX entry layer around the pinned `crawlab-ui`.
- `frontend/src/brand.css` owns visual branding and layout overrides.
- `patches/crawlab-ui@0.6.2-11.patch` disables upstream header links and the
  GitHub iframe. The patch changes both the distributed ESM bundle and source
  component for traceability.
- Analytics initialization is disabled.
- Font Awesome, login canvas, SFC loader, SimpleMDE, logos and favicon are
  served locally.
- The Content Security Policy permits `unsafe-eval` only because Crawlab's
  bundled local SFC loader dynamically compiles plugin components.
- The production image replaces only `/app/dist`; the upstream backend,
  Nginx configuration and `/api` behavior remain unchanged.

## Upgrade Rule

Do not update one row in isolation. For every upstream upgrade:

1. Record the candidate tag, commit and image digest here.
2. Recreate and validate the frontend patch against the candidate package.
3. Run frozen install, typecheck, production build and external URL scan.
4. Test login, node state, spiders, tasks, logs, results and schedules.
5. Test database and Crawlab volume backup/restore before production rollout.
