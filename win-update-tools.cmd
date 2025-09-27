@echo off
setlocal ENABLEEXTENSIONS

rem --- Get app version ---
call win-helper-functions.cmd get_app_version
echo Get macOS VMware Tools %APPVERSION%
echo ===============================
echo (c) Dave Parsons 2011-18
echo.
rem --- Require admin ---
call win-helper-functions.cmd check_admin
if "%IS_ADMIN%"=="0" (
    echo Administrator privileges required!
    exit /b 1
)

pushd %~dp0

rem --- Detect VMware installation ---
call win-helper-functions.cmd detect_vmware

rem --- Download and copy tools ---
call win-helper-functions.cmd get_vmware_tools

popd
