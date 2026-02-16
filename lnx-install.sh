#!/bin/bash

# Source the helper
source lnx-helper-functions.sh

set -e

echo "Unlocker $(get_app_version) for VMware Workstation"
echo "====================================="
echo "(c) Dave Parsons 2011-18"

# Ensure we only use unmodified commands
restrict_path

# Make sure only root can run our script
require_root

# Detect VMware installation
detect_vmware

# Detect Python installation
check_python3

# Check if tools are already installed
check_vmware_tools_installed

# Backup VMware Files
backup_vmware_files

echo Patching...
$PYVERSION ./unlocker.py

# Get VMware Tools
get_vmware_tools
