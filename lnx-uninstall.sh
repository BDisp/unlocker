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

echo Restoring files...
cp -v ./backup-linux/vmware-vmx  /usr/lib/vmware/bin/
cp -v ./backup-linux/vmware-vmx-debug /usr/lib/vmware/bin/
cp -v ./backup-linux/vmware-vmx-stats /usr/lib/vmware/bin/
if [ -d /usr/lib/vmware/lib/libvmwarebase.so.0/ ]; then
    cp -v ./backup-linux/libvmwarebase.so.0 /usr/lib/vmware/lib/libvmwarebase.so.0/
elif [ -d /usr/lib/vmware/lib/libvmwarebase.so/ ]; then
    cp -v ./backup-linux/libvmwarebase.so /usr/lib/vmware/lib/libvmwarebase.so/
fi

echo Removing backup files...
rm -rf ./backup-linux
rm -rf ./tools
rm -f /usr/lib/vmware/isoimages/darwin*.*

echo Finished!
