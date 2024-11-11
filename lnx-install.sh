#!/bin/bash

set -e

echo "Unlocker 3.0.4 for VMware Workstation"
echo "====================================="
echo "(c) Dave Parsons 2011-18"

# Ensure we only use unmodified commands
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

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

pyversion=""
if command -v python &> /dev/null; then
    pyversion="python"
elif command -v python3 &> /dev/null; then
    pyversion="python3"
else
    echo "python could not be found"
    exit
fi

echo Patching...
$pyversion ./unlocker.py

echo Getting VMware Tools...
$pyversion gettools.py
cp ./tools/darwin*.* /usr/lib/vmware/isoimages/

echo Finished!
