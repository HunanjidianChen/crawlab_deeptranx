param(
    [string]$Destination
)

. "$PSScriptRoot\common.ps1"

Assert-Docker
Ensure-EnvFile

if (-not $Destination) {
    $Destination = Join-Path $ProjectRoot ("backup\" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
}

$backupRoot = [System.IO.Path]::GetFullPath($Destination)
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot 'backup'))
if (-not $backupRoot.StartsWith($allowedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Backup destination must be inside $allowedRoot."
}

New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

$mongoId = (& docker compose --project-directory $ProjectRoot --env-file $EnvFile -f $ComposeFile ps -q mongo).Trim()
$crawlabId = (& docker compose --project-directory $ProjectRoot --env-file $EnvFile -f $ComposeFile ps -q crawlab).Trim()
if (-not $mongoId -or -not $crawlabId) {
    throw 'MongoDB and Crawlab must both be running before backup.'
}

Invoke-Compose stop crawlab
try {
    & docker exec $mongoId mongodump --archive=/tmp/deeptranx-mongo.archive.gz --gzip
    if ($LASTEXITCODE -ne 0) {
        throw 'MongoDB backup failed.'
    }
    & docker cp "${mongoId}:/tmp/deeptranx-mongo.archive.gz" (Join-Path $backupRoot 'mongo.archive.gz')
    if ($LASTEXITCODE -ne 0) {
        throw 'Copying the MongoDB backup failed.'
    }
    & docker exec $mongoId rm -f /tmp/deeptranx-mongo.archive.gz

    $runtimeImage = (& docker inspect --format '{{.Config.Image}}' $crawlabId).Trim()
    & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup" --entrypoint /bin/sh $runtimeImage -c 'tar -C /root -czf /backup/crawlab-data.tar.gz .crawlab'
    if ($LASTEXITCODE -ne 0) {
        throw 'Crawlab data backup failed.'
    }
    & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup" --entrypoint /bin/sh $runtimeImage -c 'tar -C /root -czf /backup/crawlab-workspace.tar.gz crawlab_workspace'
    if ($LASTEXITCODE -ne 0) {
        throw 'Crawlab workspace backup failed.'
    }
    & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup" --entrypoint /bin/sh $runtimeImage -c 'tar -C /data -czf /backup/crawlab-files.tar.gz seaweedfs'
    if ($LASTEXITCODE -ne 0) {
        throw 'Crawlab file service backup failed.'
    }
    & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup" --entrypoint /bin/sh $runtimeImage -c 'tar -C /data -czf /backup/bhol-exports.tar.gz exports'
    if ($LASTEXITCODE -ne 0) {
        throw 'BHOL JSONL export backup failed.'
    }

    $metadata = [ordered]@{
        createdAt = (Get-Date).ToString('o')
        crawlabVersion = '0.6.3'
        crawlabCommit = '2dbc7373eb33f2ecd2c13e6a408c90aa72574ca7'
        frontendVersion = '0.1.0'
        bholDatabase = 'bhol_pipeline'
        includesCrawlabWorkspace = $true
        includesCrawlabFiles = $true
        includesBholExports = $true
    }
    $metadata | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $backupRoot 'metadata.json') -Encoding UTF8
}
finally {
    Invoke-Compose start crawlab
}

Write-Host "Backup created: $backupRoot"
