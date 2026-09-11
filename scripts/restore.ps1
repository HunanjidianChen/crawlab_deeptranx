param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [switch]$Force
)

. "$PSScriptRoot\common.ps1"

Assert-Docker
Ensure-EnvFile

$backupRoot = [System.IO.Path]::GetFullPath($Source)
$allowedRoot = [System.IO.Path]::GetFullPath((Join-Path $ProjectRoot 'backup'))
if (-not $backupRoot.StartsWith($allowedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Backup source must be inside $allowedRoot."
}

$mongoArchive = Join-Path $backupRoot 'mongo.archive.gz'
$crawlabArchive = Join-Path $backupRoot 'crawlab-data.tar.gz'
$crawlabWorkspaceArchive = Join-Path $backupRoot 'crawlab-workspace.tar.gz'
$crawlabRepoArchive = Join-Path $backupRoot 'crawlab-repo.tar.gz'
$crawlabStorageArchive = Join-Path $backupRoot 'crawlab-storage.tar.gz'
$crawlabFilesArchive = Join-Path $backupRoot 'crawlab-files.tar.gz'
$bholExportsArchive = Join-Path $backupRoot 'bhol-exports.tar.gz'
if (-not (Test-Path -LiteralPath $mongoArchive) -or -not (Test-Path -LiteralPath $crawlabArchive)) {
    throw 'The backup must contain mongo.archive.gz and crawlab-data.tar.gz.'
}

if (-not $Force) {
    $answer = Read-Host 'Restore will replace current DeepTranX data. Type RESTORE to continue'
    if ($answer -cne 'RESTORE') {
        throw 'Restore cancelled.'
    }
}

$mongoId = (& docker compose --project-directory $ProjectRoot --env-file $EnvFile -f $ComposeFile ps -q mongo).Trim()
$crawlabId = (& docker compose --project-directory $ProjectRoot --env-file $EnvFile -f $ComposeFile ps -q crawlab).Trim()
if (-not $mongoId -or -not $crawlabId) {
    throw 'MongoDB and Crawlab containers must exist before restore.'
}

Invoke-Compose stop crawlab
try {
    & docker cp $mongoArchive "${mongoId}:/tmp/deeptranx-mongo.archive.gz"
    if ($LASTEXITCODE -ne 0) {
        throw 'Copying the MongoDB archive failed.'
    }
    & docker exec $mongoId mongorestore --drop --archive=/tmp/deeptranx-mongo.archive.gz --gzip
    if ($LASTEXITCODE -ne 0) {
        throw 'MongoDB restore failed.'
    }

    $runtimeImage = (& docker inspect --format '{{.Config.Image}}' $crawlabId).Trim()
    & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup:ro" --entrypoint /bin/sh $runtimeImage -c 'find /root/.crawlab -mindepth 1 -maxdepth 1 -exec rm -rf {} +; tar -C /root -xzf /backup/crawlab-data.tar.gz'
    if ($LASTEXITCODE -ne 0) {
        throw 'Crawlab data restore failed.'
    }
    if (Test-Path -LiteralPath $crawlabWorkspaceArchive) {
        & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup:ro" --entrypoint /bin/sh $runtimeImage -c 'find /root/crawlab_workspace -mindepth 1 -maxdepth 1 -exec rm -rf {} +; tar -C /root -xzf /backup/crawlab-workspace.tar.gz'
        if ($LASTEXITCODE -ne 0) {
            throw 'Crawlab workspace restore failed.'
        }
    }
    if (Test-Path -LiteralPath $crawlabRepoArchive) {
        & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup:ro" --entrypoint /bin/sh $runtimeImage -c 'find /root/crawlab_repo -mindepth 1 -maxdepth 1 -exec rm -rf {} +; tar -C /root -xzf /backup/crawlab-repo.tar.gz'
        if ($LASTEXITCODE -ne 0) {
            throw 'Crawlab Git repository restore failed.'
        }
    }
    if (Test-Path -LiteralPath $crawlabStorageArchive) {
        & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup:ro" --entrypoint /bin/sh $runtimeImage -c 'find /data -mindepth 1 -maxdepth 1 ! -name seaweedfs ! -name exports -exec rm -rf {} +; tar -C /data -xzf /backup/crawlab-storage.tar.gz'
        if ($LASTEXITCODE -ne 0) {
            throw 'Crawlab file content restore failed.'
        }
    }
    if (Test-Path -LiteralPath $crawlabFilesArchive) {
        & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup:ro" --entrypoint /bin/sh $runtimeImage -c 'find /data/seaweedfs -mindepth 1 -maxdepth 1 -exec rm -rf {} +; tar -C /data -xzf /backup/crawlab-files.tar.gz'
        if ($LASTEXITCODE -ne 0) {
            throw 'Crawlab file service restore failed.'
        }
    }
    if (Test-Path -LiteralPath $bholExportsArchive) {
        & docker run --rm --volumes-from $crawlabId --volume "${backupRoot}:/backup:ro" --entrypoint /bin/sh $runtimeImage -c 'find /data/exports -mindepth 1 -maxdepth 1 -exec rm -rf {} +; tar -C /data -xzf /backup/bhol-exports.tar.gz'
        if ($LASTEXITCODE -ne 0) {
            throw 'BHOL JSONL export restore failed.'
        }
    }
}
finally {
    & docker exec $mongoId rm -f /tmp/deeptranx-mongo.archive.gz 2>$null
    Invoke-Compose start crawlab
}

Write-Host "Restore completed from: $backupRoot"
