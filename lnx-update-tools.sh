#!/bin/bash

set -e

echo "Get macOS VMware Tools 3.0.4"
echo "==============================="
echo "(c) Dave Parsons 2015-18"

# Ensure we only use unmodified commands
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
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

echo Getting VMware Tools...
$pyversion gettools.py
cp ./tools/darwin*.* /usr/lib/vmware/isoimages/

echo Finished!
