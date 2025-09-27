macOS Unlocker V3.0 for VMware Workstation
==========================================

***
### <div align="center">READ HERE:</div>

WINDOWS USERS: Get the tool from the Releases section, you will get a bundled python distribution that avoids the virus warnings and python not found etc.

LINUX USERS: No bundled python for you, but make sure you have python 3.0+ installed. If you have errors like "Python not supported" but you have python installed, run the script with `PYVERSION=python3.7` (if you have python 3.7 installed, otherwise try python3 or other stuff)

***
<table align="center"><tr><td align="center" width="9999">

| IMPORTANT:
| ---
| Always uninstall the previous version of the Unlocker before using a new version.
| Failure to do this could render VMware unusable.

</td></tr></table>

***

### 1. Introduction
---------------

Unlocker 3 is designed for VMware Workstation 11-17 and Player 7-17.

If you are using an earlier product please continue using Unlocker 1.

Version 3 has been tested against:

* Workstation 11/12/14/15/16/17 on Windows and Linux
* Workstation Player 7/12/14/15/16/17 on Windows and Linux

The patch code carries out the following modifications dependent on the product
being patched:

* Fix vmware-vmx and derivatives to allow macOS to boot
* Fix vmwarebase .dll or .so to allow Apple to be selected during VM creation
* Download a copy of the latest VMware Tools for macOS

Note that not all products recognize the darwin.iso via install tools menu item.
You will have to manually mount the darwin.iso for example on Workstation 11 and Player 7.

In all cases make sure VMware is not running, and any background guests have
been shutdown.

The code is written in Python.

### 2. Prerequisites
----------------

The code requires Python 3.0 or later to work. Most Linux distros ship with a compatible
Python interpreter and should work without requiring any additional software.

Windows Unlocker has a packaged version of the Python script using PyInstaller, 
and so does not require Python to be installed.

### 3. Limitations
--------------

If you are using VMware Player or Workstation on Windows you may get a core dump.

Latest Linux products are OK and do not show this problem.

<table align="center"><tr><td align="center" width="9999">
   
| IMPORTANT:
| ---
| If you create a new VM VMware may stop and create a core dump.
| There are two options to work around this issue:
| 1. Change the VM to be HW 10 - this does not affect performance.
| 2. Edit the VMX file and add:<br/>smc.version = "0"
   
</td></tr></table>

### 4. Windows
----------
On Windows you will need to either run cmd.exe as Administrator or using
Explorer right click on the command file and select "Run as administrator".

- win-install.cmd - patches VMware
- win-uninstall.cmd - restores VMware
- win-update-tools.cmd - retrieves latest macOS guest tools

### 5. Linux
---------
On Linux you will need to be either root or use sudo to run the scripts.

You may need to ensure the Linux scripts have execute permissions
by running chmod +x against the 2 files.

- lnx-install.sh   - patches VMware
- lnx-uninstall.sh - restores VMware
- lnx-update-tools.sh - retrieves latest macOS guest tools
   
### 6. Thanks
---------

Thanks to Zenith432 for originally building the C++ unlocker and Mac Son of Knife
(MSoK) for all the testing and support.

Thanks also to Sam B for finding the solution for ESXi 6 and helping me with
debugging expertise. Sam also wrote the code for patching ESXi ELF files and
modified the unlocker code to run on Python 3 in the ESXi 6.5 environment.


History
-------

| Date | Release | Description
| --- | --- | ---
| 27/09/2018 | 3.0.0 | First release
| 02/10/2018 | 3.0.1 | Fixed gettools.py to work with Python 3 and correctly download darwinPre15.iso
| 10/10/2018 | 3.0.2 | Fixed false positives from anti-virus software with Windows executables<br/>- Allow Python 2 and 3 to run the Python code from Bash scripts
| 10/24/2019 | 3.0.3 | Fixed unlocker and gettools for VMware Workstation 15.5
| 11/05/2021 | 3.0.4 | Fixed gettools for VMware Workstation 16.2.0 build-18760230 and add separates backups folders for each OS
| 15/12/2022 | 3.0.5 | Fixed gettools for VMware Workstation 17.0.0 build-20800274
| 06/02/2023 | 3.0.6 | Fixed gettools for VMware Workstation 17.0.1 build-21139696
| 27/05/2024 | 3.0.7 | Fixed gettools for HTTP Error 403: Forbidden
| 11/11/2024 | 3.0.8 | Fixed gettools for File not found darwin
| 24/03/2025 | 3.0.9 | Fixed gettools for IndexError: list index out of range
| 28/03/2025 | 3.1.0 | Fixed Error: \VMware\VMware was unexpected at this time.

(c) 2011-2018 Dave Parsons
