$ErrorActionPreference = 'Stop'

$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
$script:ComposeFile = Join-Path $ProjectRoot 'deploy\compose.yml'
$script:EnvFile = Join-Path $ProjectRoot '.env'
$script:EnvExample = Join-Path $ProjectRoot '.env.example'
$script:UpstreamCrawlabImage = 'crawlabteam/crawlab:0.6.3@sha256:9dbe97240ba2670ce49fd1be5d557b59653e602d8fa29a71c9e05b26c557193b'

function Assert-Docker {
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & docker info 1>$null 2>$null
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        throw 'Docker Desktop Linux engine is not available.'
    }
}

function Ensure-EnvFile {
    if (-not (Test-Path -LiteralPath $EnvFile)) {
        Copy-Item -LiteralPath $EnvExample -Destination $EnvFile
        throw '.env was created from .env.example. Replace both authentication keys, then run the command again.'
    }
}

function Invoke-Compose {
    $previousComposeBake = $env:COMPOSE_BAKE
    $env:COMPOSE_BAKE = 'false'
    try {
        & docker compose --project-directory $ProjectRoot --env-file $EnvFile -f $ComposeFile @args
        $exitCode = $LASTEXITCODE
    }
    finally {
        if ($null -eq $previousComposeBake) {
            Remove-Item Env:\COMPOSE_BAKE -ErrorAction SilentlyContinue
        }
        else {
            $env:COMPOSE_BAKE = $previousComposeBake
        }
    }
    if ($exitCode -ne 0) {
        throw "docker compose failed with exit code $exitCode."
    }
}
