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
