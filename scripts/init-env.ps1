$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $projectRoot '.env'
$exampleFile = Join-Path $projectRoot '.env.example'

if (Test-Path -LiteralPath $envFile) {
    throw '.env already exists. It was not changed.'
}

function New-Secret {
    $bytes = New-Object byte[] 32
    $generator = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $generator.GetBytes($bytes)
    }
    finally {
        $generator.Dispose()
    }
    return ([System.BitConverter]::ToString($bytes) -replace '-', '').ToLowerInvariant()
}

$content = Get-Content -LiteralPath $exampleFile -Raw
$content = $content.Replace('change-this-grpc-auth-key', (New-Secret))
$content = $content.Replace('change-this-filer-auth-key', (New-Secret))
Set-Content -LiteralPath $envFile -Value $content -Encoding UTF8

Write-Host '.env created with random authentication keys.'
