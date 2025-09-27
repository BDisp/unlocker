#!/bin/bash

# Dry run (preview only):
# bash ./package.sh --dry-run

# Real packaging (creates archives):
# ./package.sh

set -euo pipefail

VERSION=$(cat VERSION)
DRYRUN=false
RELEASE_DIR="release"

# Parse optional args
if [[ "${1:-}" == "--dry-run" ]]; then
    DRYRUN=true
fi

# Whitelist files for packaging
WINDOWS_FILES=(
    "LICENSE"
    "README.md"
    "README.zh-CN.md"
    "VERSION"
    "win-helper-functions.cmd"
    "win-install.cmd"
    "win-uninstall.cmd"
    "win-update-tools.cmd"
    "dumpsmc.exe"
    "gettools.exe"
    "unlocker.exe"
)
LINUX_FILES=(
    "LICENSE"
    "README.md"
    "README.zh-CN.md"
    "VERSION"
    "lnx-helper-functions.sh"
    "lnx-install.sh"
    "lnx-uninstall.sh"
    "lnx-update-tools.sh"
    "dumpsmc.py"
    "gettools.py"
    "unlocker.py"
)

# Function to check files existence
check_files() {
    local files=("$@")
    local missing=0

    for f in "${files[@]}"; do
        if [[ ! -e "$f" ]]; then
            echo "⚠️  Missing file: $f"
            missing=1
        fi
    done

    if [[ $missing -ne 0 ]]; then
        echo "❌ One or more whitelisted files are missing. Aborting."
        exit 1
    fi
}

# Function to package files
package() {
    local name="$1"
    shift
    local files=("$@")

    # Check all files exist
    check_files "${files[@]}"

    if $DRYRUN; then
        echo "👉 Would create $name containing:"
        for f in "${files[@]}"; do
            echo "   - $f"
        done
        echo
    else
        # Ensure release folder exists
        mkdir -p "$RELEASE_DIR"

        case "$name" in
            *.zip) zip -r "$RELEASE_DIR/$name" "${files[@]}" ;;
            *.tar.gz) tar -czvf "$RELEASE_DIR/$name" "${files[@]}" ;;
        esac
        echo "✅ Created $RELEASE_DIR/$name"
    fi
}

# Clean previous release folder if it exists
if [[ -d "$RELEASE_DIR" && "$DRYRUN" = false ]]; then
    echo "🗑️  Removing previous release folder..."
    rm -rf "$RELEASE_DIR"
fi

# Run packaging
package "Unlocker-Windows-${VERSION}.zip" "${WINDOWS_FILES[@]}"
package "Unlocker-Linux-${VERSION}.tar.gz" "${LINUX_FILES[@]}"
