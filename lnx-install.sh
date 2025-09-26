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

echo Creating backup-linux folder...
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

# Detect Python installation
check_python3

echo Patching...
$PYVERSION ./unlocker.py

# Get VMware Tools
get_vmware_tools