. "$PSScriptRoot\common.ps1"

Assert-Docker
Ensure-EnvFile
Invoke-Compose --profile dev rm -f -s frontend-dev
Invoke-Compose up -d --build mongo crawlab

Write-Host 'DeepTranX: http://localhost:8080'
