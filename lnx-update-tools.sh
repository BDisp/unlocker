#!/bin/bash

# Source the helper
source lnx-helper-functions.sh

set -e

echo "Get macOS VMware Tools $(get_app_version)"
echo "==============================="
echo "(c) Dave Parsons 2015-18"

# Ensure we only use unmodified commands
restrict_path

# Make sure only root can run our script
require_root

# Detect VMware installation
detect_vmware

# Detect Python installation
check_python3

# Get VMware Tools
get_vmware_tools