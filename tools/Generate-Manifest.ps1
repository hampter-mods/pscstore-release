param(
    [string]$FilesRoot = (Join-Path $PSScriptRoot "..\files"),
    [string]$ManifestPath = (Join-Path $PSScriptRoot "..\manifest.tsv"),
    [string]$ReleaseVersion = ""
)

$ErrorActionPreference = "Stop"

function Get-UpdatePolicy {
    param([string]$DestPath)

    if ($DestPath -like "*/SUP/scripts/*") { return "shutdown" }
    if ($DestPath -like "*/FUNC/*.funcs") { return "shutdown" }
    if ($DestPath -like "*/SUP/launchers/pscstore/launch.sh") { return "shutdown" }
    if ($DestPath -like "*/opt/retroarch/retroarch") { return "shutdown" }
    return "restart"
}

function Get-InstallMode {
    param([string]$DestPath)

    if ($DestPath -like "*/SUP/scripts/*") { return "0755" }
    if ($DestPath -like "*/SUP/binaries/*") { return "0755" }
    if ($DestPath -like "*/FUNC/*.funcs") { return "0755" }
    if ($DestPath -like "*/SUP/launchers/pscstore/pscstore") { return "0755" }
    if ($DestPath -like "*/SUP/launchers/pscstore/pscstore_logger") { return "0755" }
    if ($DestPath -like "*/SUP/launchers/pscstore/launch.sh") { return "0755" }
    if ($DestPath -like "*/opt/retroarch/retroarch") { return "0755" }
    return "0644"
}

function Test-LfNormalizedPayload {
    param([string]$DestPath)

    if ($DestPath -like "*/FUNC/*.funcs") { return $true }
    if ($DestPath -like "*/SUP/scripts/*") { return $true }
    if ($DestPath -like "*/SUP/launchers/pscstore/launch.sh") { return $true }
    return $false
}

function Convert-FileToLf {
    param([string]$Path)

    $text = [System.IO.File]::ReadAllText($Path)
    $lf = $text -replace "`r`n", "`n"
    $lf = $lf -replace "`r", "`n"
    if ($lf -ne $text) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($Path, $lf, $utf8NoBom)
    }
}

$root = (Resolve-Path -LiteralPath $FilesRoot).Path.TrimEnd('\', '/')
$rows = New-Object System.Collections.Generic.List[string]
$versionFile = Join-Path $root "media/project_eris/etc/project_eris/SUP/launchers/pscstore/cache/release_version.txt"
$legacyVersionFile = Join-Path $root "media/project_eris/etc/project_eris/SUP/launchers/pscstore/release_version.txt"
$legacyVersionBackup = "$legacyVersionFile.update_bak"
if ((Test-Path -LiteralPath $legacyVersionFile) -and -not (Test-Path -LiteralPath $versionFile)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $versionFile) | Out-Null
    Copy-Item -LiteralPath $legacyVersionFile -Destination $versionFile -Force
}
if (Test-Path -LiteralPath $legacyVersionFile) {
    Remove-Item -LiteralPath $legacyVersionFile -Force
}
if (Test-Path -LiteralPath $legacyVersionBackup) {
    Remove-Item -LiteralPath $legacyVersionBackup -Force
}
$version = $ReleaseVersion.Trim()
if (-not $version -and (Test-Path -LiteralPath $versionFile)) {
    $version = ((Get-Content -LiteralPath $versionFile -TotalCount 1) -as [string]).Trim()
}
if (-not $version) { $version = "unknown" }
$notesPath = Join-Path (Split-Path -Parent $ManifestPath) "release-notes/$version.txt"
$rows.Add("# pscstore update manifest v1")
$rows.Add("@version|$version")
if (Test-Path -LiteralPath $notesPath) {
    $rows.Add("@notes_url|release-notes/$version.txt")
}
$rows.Add("# md5|size|mode|policy|path|url")

Get-ChildItem -LiteralPath $root -Recurse -File |
    Sort-Object FullName |
    ForEach-Object {
        $relative = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
        $dest = "/" + $relative
        if (Test-LfNormalizedPayload $dest) {
            Convert-FileToLf $_.FullName
            $_ = Get-Item -LiteralPath $_.FullName
        }
        $md5 = (Get-FileHash -LiteralPath $_.FullName -Algorithm MD5).Hash.ToLowerInvariant()
        $mode = Get-InstallMode $dest
        $policy = Get-UpdatePolicy $dest
        $rows.Add("$md5|$($_.Length)|$mode|$policy|$dest|$relative")
    }

Set-Content -LiteralPath $ManifestPath -Value $rows -Encoding ASCII
Write-Host "Wrote $ManifestPath"
