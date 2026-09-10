. "$PSScriptRoot\common.ps1"

Assert-Docker
Ensure-EnvFile

Write-Host 'Validating Docker Compose configuration...'
Invoke-Compose config --quiet

Write-Host 'Running frontend frozen install, typecheck and production build in Node 18.20...'
& docker run --rm `
    --volume "${ProjectRoot}:/workspace" `
    --workdir /workspace/frontend `
    node:18.20.8-bookworm-slim `
    sh -lc 'corepack enable && corepack prepare pnpm@7.33.7 --activate && pnpm install --frozen-lockfile && pnpm typecheck && pnpm build'
if ($LASTEXITCODE -ne 0) {
    throw 'Frontend verification failed.'
}

$assetFiles = Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'frontend\dist') -Recurse -File |
    Where-Object { $_.Extension -in @('.html', '.css') }
$externalReferences = $assetFiles |
    Select-String -Pattern '(src|href|url\()\s*=?\s*["'']?https?://' |
    Select-Object -ExpandProperty Line -Unique
if ($externalReferences) {
    throw "Unexpected external asset references remain:`n$($externalReferences -join "`n")"
}

Write-Host 'Static verification completed. Confirm runtime requests in the browser Network panel.'
