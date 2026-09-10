. "$PSScriptRoot\common.ps1"

Ensure-EnvFile

$settings = @{}
Get-Content -LiteralPath $EnvFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)=(.*)$') {
        $settings[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$port = if ($settings.APP_PORT) { $settings.APP_PORT } else { '8080' }
$response = Invoke-RestMethod -Uri "http://127.0.0.1:$port/api/system-info" -TimeoutSec 10
$response | ConvertTo-Json -Depth 10
