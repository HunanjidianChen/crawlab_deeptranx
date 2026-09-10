. "$PSScriptRoot\common.ps1"

Assert-Docker
Ensure-EnvFile
Invoke-Compose --profile dev down
