from __future__ import print_function

import sys
import shutil
import unlocker

# Check minimal Python version is 3
if sys.version_info < (3, 0):
    sys.stderr.write('You need Python 3 or later\n')
    sys.exit(1)


def main():
    # Test Windows patching
    print('Windows Workstation 12')
    shutil.copyfile('./samples/windows/wks12/vmware-vmx.exe', './tests/windows/wks12/vmware-vmx.exe')
    unlocker.patchsmc('./tests/windows/wks12/vmware-vmx.exe', False)
    shutil.copyfile('./samples/windows/wks12/vmwarebase.dll', './tests/windows/wks12/vmwarebase.dll')
    unlocker.patchbase('./tests/windows/wks12/vmwarebase.dll')

    print('Windows Workstation 14')
    shutil.copyfile('./samples/windows/wks14/vmware-vmx.exe', './tests/windows/wks14/vmware-vmx.exe')
    unlocker.patchsmc('./tests/windows/wks14/vmware-vmx.exe', False)
    shutil.copyfile('./samples/windows/wks14/vmwarebase.dll', './tests/windows/wks14/vmwarebase.dll')
    unlocker.patchbase('./tests/windows/wks14/vmwarebase.dll')

    # Test Linux patching
    print('Linux Workstation 12')
    shutil.copyfile('./samples/linux/wks12/vmware-vmx', './tests/linux/wks12/vmware-vmx')
    unlocker.patchsmc('./tests/linux/wks12/vmware-vmx', True)
    shutil.copyfile('./samples/linux/wks12/libvmwarebase.so', './tests/linux/wks12/libvmwarebase.so')
    unlocker.patchbase('./tests/linux/wks12/libvmwarebase.so')

    print('Linux Workstation 14')
    shutil.copyfile('./samples/linux/wks14/vmware-vmx', './tests/linux/wks14/vmware-vmx')
    unlocker.patchsmc('./tests/linux/wks14/vmware-vmx', True)
    unlocker.patchbase('./tests/linux/wks14/vmware-vmx')
    shutil.copyfile('./samples/linux/wks14/libvmwarebase.so', './tests/linux/wks14/libvmwarebase.so')
    unlocker.patchbase('./tests/linux/wks14/libvmwarebase.so')

    # Test macOS patching
    print('macOS Fusion 8')
    shutil.copyfile('./samples/macos/fus8/vmware-vmx', './tests/macos/fus8/vmware-vmx')
    unlocker.patchsmc('./tests/macos/fus8/vmware-vmx', False)

    print('macOS Fusion 10')
    shutil.copyfile('./samples/macos/fus10/vmware-vmx', './tests/macos/fus10/vmware-vmx')
    unlocker.patchsmc('./tests/macos/fus10/vmware-vmx', False)

    # Test ESXi patching
    print('ESXi 6.0')
    shutil.copyfile('./samples/esxi/esxi600/vmx', './tests/esxi/esxi600/vmx')
    unlocker.patchsmc('./tests/esxi/esxi600/vmx', True)
    shutil.copyfile('./samples/esxi/esxi600/libvmkctl.so', './tests/esxi/esxi600/libvmkctl.so')
    unlocker.patchvmkctl('./tests/esxi/esxi600/libvmkctl.so')

    print('ESXi 6.5')
    shutil.copyfile('./samples/esxi/esxi650/vmx', './tests/esxi/esxi650/vmx')
    unlocker.patchsmc('./tests/esxi/esxi650/vmx', True)
    shutil.copyfile('./samples/esxi/esxi650/lib/libvmkctl.so', './tests/esxi/esxi650/lib/libvmkctl.so')
    unlocker.patchvmkctl('./tests/esxi/esxi650/lib/libvmkctl.so')
    shutil.copyfile('./samples/esxi/esxi650/lib64/libvmkctl.so', './tests/esxi/esxi650/lib64/libvmkctl.so')
    unlocker.patchvmkctl('./tests/esxi/esxi650/lib64/libvmkctl.so')
    shutil.copyfile('./samples/esxi/esxi650/config.xml', './tests/esxi/esxi650/config.xml')


if __name__ == '__main__':
    main()
