# package.ps1
<#
.SYNOPSIS
Package Unlocker for Windows and Linux.
.DESCRIPTION
Creates Unlocker-Windows-{VERSION}.zip and Unlocker-Linux-{VERSION}.tar.gz.
Supports --dry-run to preview without creating files.
#>

param(
    [switch]$DryRun
)

# --- Get version from VERSION file ---
$VersionFile = "VERSION"
if (-Not (Test-Path $VersionFile)) {
    Write-Error "VERSION file not found!"
    exit 1
}
$VERSION = Get-Content $VersionFile -Raw
$VERSION = $VERSION.Trim()

# --- Whitelist files ---
$WindowsFiles = @(
    "LICENSE",
    "README.md",
    "README.zh-CN.md",
    "VERSION",
    "win-helper-functions.cmd",
    "win-install.cmd",
    "win-uninstall.cmd",
    "win-update-tools.cmd",
    "dumpsmc.exe",
    "gettools.exe",
    "unlocker.exe"
)

$LinuxFiles = @(
    "LICENSE",
    "README.md",
    "README.zh-CN.md",
    "VERSION",
    "lnx-helper-functions.sh",
    "lnx-install.sh",
    "lnx-uninstall.sh",
    "lnx-update-tools.sh",
    "dumpsmc.py",
    "gettools.py",
    "unlocker.py"
)

# --- Check if files exist ---
function Check-FilesExist {
    param([string[]]$Files, [string]$OSName)
    $Missing = @()
    foreach ($f in $Files) {
        if (-not (Test-Path $f)) {
            $Missing += $f
            Write-Warning "⚠️ Missing file: $f"
        }
    }
    if ($Missing.Count -gt 0) {
        Write-Error "❌ One or more whitelisted files are missing for $OSName. Aborting."
        exit 1
    }
}

# --- Create release folder ---
$ReleaseDir = "release"
if (Test-Path $ReleaseDir) {
    Write-Host "🗑️  Removing previous release folder..."
    Remove-Item -Recurse -Force $ReleaseDir
}
New-Item -ItemType Directory -Path $ReleaseDir | Out-Null

# --- Function to package ---
function Package-Files {
    param(
        [string]$ArchiveName,
        [string[]]$Files
    )

    if ($DryRun) {
        Write-Host "👉 Would create $ArchiveName containing:"
        foreach ($f in $Files) {
            Write-Host "   - $f"
        }
        Write-Host ""
        return
    }

    # Windows zip
    if ($ArchiveName -like "*.zip") {
        Write-Host "Creating $ArchiveName..."
        Compress-Archive -Path $Files -DestinationPath "$ReleaseDir\$ArchiveName" -Force -Verbose
    }
    # Linux tar.gz
    elseif ($ArchiveName -like "*.tar.gz") {
        Write-Host "Creating $ArchiveName..."
        $FullPath = Join-Path $ReleaseDir $ArchiveName
        # Requires tar.exe on Windows 10+
        tar -czvf $FullPath $Files
    }

    Write-Host "✅ Created $ArchiveName"
}

# --- Run checks ---
Check-FilesExist -Files $WindowsFiles -OSName "Windows"
Check-FilesExist -Files $LinuxFiles -OSName "Linux"

# --- Package ---
Package-Files -ArchiveName "Unlocker-Windows-$VERSION.zip" -Files $WindowsFiles
Package-Files -ArchiveName "Unlocker-Linux-$VERSION.tar.gz" -Files $LinuxFiles

Write-Host "`nAll done!"
