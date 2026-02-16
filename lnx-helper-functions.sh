#!/bin/bash

# Get application version from git tag or VERSION file
get_app_version() {
    if [ -d .git ]; then
        git describe --tags --abbrev=0 2>/dev/null || echo "unknown"
    elif [ -f VERSION ]; then
        cat VERSION
    else
        echo "unknown"
    fi
}

# Restrict PATH to unmodified system commands
restrict_path() {
    export PATH=/bin:/sbin:/usr/bin:/usr/sbin
}

# Require root privileges
require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

# Detect VMware installation and version
detect_vmware() {
    VMWARE_PATH=""

    if [ -d "/usr/lib/vmware/" ]; then
        VMWARE_PATH="/usr/lib/vmware/"
    fi

    if [ -z "$VMWARE_PATH" ]; then
        echo "VMware is not installed"
        return 1
    fi

    # Try to get product version if available
    if [ -f "/etc/vmware/config" ]; then
        PRODUCT_VERSION=$(grep -m1 -i "product.version" /etc/vmware/config | awk -F'"' '{print $2}')
    elif command -v vmware &>/dev/null; then
        PRODUCT_VERSION=$(vmware -v 2>/dev/null)
    else
        PRODUCT_VERSION="unknown"
    fi

    echo "VMware product version: $PRODUCT_VERSION"
}

# ----------------------------------------------------------------------
# Function: check_vmware_tools_installed
#   - Checks if the key VMware Tools files are already present in the script location
#   - Echoes status message
#   - Sets global variable CHECK_INSTALLED=1 if found, 0 otherwise
# ----------------------------------------------------------------------
check_vmware_tools_installed() {
    CHECK_INSTALLED=0

    # Get directory where the script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    BACKUP_FOLDER="$SCRIPT_DIR/backup-linux"

    echo "Checking for backup folder: $BACKUP_FOLDER"

    if [ -d "$BACKUP_FOLDER" ]; then
        CHECK_INSTALLED=1
        echo ""
        echo "VMware Tools backup folder found: backup-linux"
        echo "Appears to be already present/installed."
        echo "Skipping installation."
        echo "Run lnx-uninstall.sh first to remove tools and restore original files."
        echo ""
        exit 1
    else
        echo "No backup-linux folder found in script directory."
        echo "Proceeding with installation..."
        echo ""
    fi
}

# Check Python 3 interpreter
check_python3() {
    PYVERSION="${PYVERSION:-python3}"

    if ! command -v "$PYVERSION" &> /dev/null; then
        echo "Python 3 interpreter '$PYVERSION' not found."
        exit 1
    fi

    # Optional: ensure version >= 3
    VERSION=$($PYVERSION -c 'import sys; print(sys.version_info[0])')
    if [ "$VERSION" -lt 3 ]; then
        echo "Python 3 is required. '$PYVERSION' is Python $VERSION."
        exit 1
    fi

    echo Python version installed: $($PYVERSION --version)
}

# Function to get VMware Tools
get_vmware_tools() {
    echo "Getting VMware Tools..."

    # Run the Python script
    $PYVERSION gettools.py || {
        echo "Failed to run gettools.py"
        exit 1
    }

    if [ -d "${VMWARE_PATH}isoimages/" ]; then
        cp ./tools/darwin*.* "${VMWARE_PATH}isoimages/"
        echo "Copied VMware Tools ISOs."
    fi

    echo "Finished!"
}

# Function to Backup VMware files
backup_vmware_files(){
    echo "Creating backup-linux folder..."
    rm -rf ./backup-linux
    mkdir -p "./backup-linux"
    cp -v /usr/lib/vmware/bin/vmware-vmx ./backup-linux/
    cp -v /usr/lib/vmware/bin/vmware-vmx-debug ./backup-linux/
    cp -v /usr/lib/vmware/bin/vmware-vmx-stats ./backup-linux/
    if [ -d /usr/lib/vmware/lib/libvmwarebase.so.0/ ]; then
        cp -v /usr/lib/vmware/lib/libvmwarebase.so.0/libvmwarebase.so.0 ./backup-linux/
    elif [ -d /usr/lib/vmware/lib/libvmwarebase.so/ ]; then
        cp -v /usr/lib/vmware/lib/libvmwarebase.so/libvmwarebase.so ./backup-linux/
    fi
}
