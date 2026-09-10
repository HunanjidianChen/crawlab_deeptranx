. "$PSScriptRoot\common.ps1"

Assert-Docker
Ensure-EnvFile

$env:CRAWLAB_IMAGE = $UpstreamCrawlabImage
try {
    Invoke-Compose --profile dev up -d --no-build
}
finally {
    Remove-Item Env:\CRAWLAB_IMAGE -ErrorAction SilentlyContinue
}

Write-Host 'DeepTranX development frontend: http://localhost:5173'
Write-Host 'Crawlab backend and official frontend: http://localhost:8080'
