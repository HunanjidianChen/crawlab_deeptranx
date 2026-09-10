. "$PSScriptRoot\common.ps1"

Assert-Docker
Ensure-EnvFile
Invoke-Compose build --pull crawlab

Write-Host 'Built deeptranx/crawlab:0.1.0-crawlab0.6.3.'
