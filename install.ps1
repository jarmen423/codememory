# install.ps1 - Windows installer for codememory

param(
    [switch]$UI,
    [string]$InstallDir = "$env:USERPROFILE\.localin",
    [switch]$SkipConfig
)

$ErrorActionPreference = "Stop"
$Repo = "jarmen423/codememory"
$BinaryName = "codememory"

Write-Host "-> Installing codememory (Windows) to $InstallDir"

$Arch = "amd64"
$Variant = if ($UI) { "ui" } else { "standard" }
$DownloadUrl = "https://github.com/$Repo/releases/latest/download/$BinaryName-windows-$Arch$Variant.zip"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$TempDir = New-TemporaryFile | ForEach-Object { $_.DirectoryName }
$ZipPath = Join-Path $TempDir "codememory.zip"

Write-Host "-> Downloading..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath

Write-Host "-> Extracting..."
Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force

$ExePath = Join-Path $InstallDir "$BinaryName.exe"
if (Test-Path $ExePath) {
    Write-Host "codememory installed successfully!"
    & $ExePath --version
} else {
    Write-Error "Installation failed"
}

if (-not $SkipConfig) {
    Write-Host "-> Running initial configuration..."
    & $ExePath config init --yes 2>$null
}

Write-Host "`nRestart your coding agent and say: Index this project"
