# Verification

## Automated Checks

Run the static and build checks:

```powershell
.\scripts\verify.ps1
.\scripts\start-prod.ps1
.\scripts\health.ps1
```

Confirm both services are healthy:

```powershell
docker compose --env-file .env -f deploy/compose.yml ps
```

The health response must report Crawlab `v0.6.3`. The production response
headers must contain the local Content Security Policy, and the HTML must not
reference CDN assets.

## Functional Acceptance

1. Sign in with `admin/admin` on a fresh database and change the password.
2. Confirm `DeepTranX Master` is enabled, online and marked as a Master node.
3. Create or upload a spider and run it on the Master node.
4. Check task status, logs, results and schedule execution.
5. Recreate the containers and confirm MongoDB data, spiders and configuration
   remain available.
6. Run `backup.ps1`, restore into a test deployment and repeat the login and
   node checks.

## Browser Acceptance

Check the login page, navigation and primary business pages at desktop and
mobile widths. Confirm there is no text overflow or overlapping UI. In the
browser Network panel, application assets must originate from the current
host; only configured business API traffic may use another host.

The CSP includes `script-src 'unsafe-eval'` for Crawlab's bundled local
`vue3-sfc-loader`. Do not broaden the policy unless a verified local feature
requires it.
