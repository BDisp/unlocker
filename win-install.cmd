@echo off
setlocal ENABLEEXTENSIONS
echo.
rem --- Get app version ---
call win-helper-functions.cmd get_app_version
echo Unlocker %APPVERSION% for VMware Workstation
echo =====================================
echo (c) Dave Parsons 2011-18
echo.
echo Set encoding parameters...
chcp 850

rem --- Require admin ---
call win-helper-functions.cmd check_admin
if "%IS_ADMIN%"=="0" (
    echo Administrator privileges required!
    exit /b 1
)

echo.
rem --- Detect VMware installation ---
call win-helper-functions.cmd detect_vmware
if "%VMWARE_INSTALLED%" == "0" (
    exit /b
)

pushd %~dp0

echo.
rem --- Stop VMware services ---
call win-helper-functions.cmd stop_vmware_services

echo.
rem --- Backup VMware Files ---
call win-helper-functions.cmd backup_vmware_files

echo.
echo Patching...
unlocker.exe

echo.
rem --- Download and copy tools ---
call win-helper-functions.cmd get_vmware_tools

echo.
rem --- Start VMware services ---
call win-helper-functions.cmd start_vmware_services

popd
echo.
echo Finished!
