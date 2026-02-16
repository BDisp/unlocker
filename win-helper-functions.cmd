@echo off
setlocal ENABLEEXTENSIONS

:: Jump to the specified label if provided
if not "%~1"=="" (
    for %%L in (%~1) do goto :%%L
)

goto :EOF

:: --- Function: Get App Version ---
:get_app_version
set "APPVERSION=unknown"
if exist VERSION (
    set /p APPVERSION=<VERSION
)
endlocal & set "APPVERSION=%APPVERSION%"
goto :EOF

:: --- Function: Check Admin ---
:check_admin
set "IS_ADMIN=0"
net session >NUL 2>&1
if %errorlevel% equ 0 (
    set "IS_ADMIN=1"
)
endlocal & set "IS_ADMIN=%IS_ADMIN%"
goto :EOF

:: --- Function: Detect VMware ---
:detect_vmware
set "INSTALLPATH="
set KeyName="HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Player"
for /f "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v InstallPath 2^>nul') do set "INSTALLPATH=%%B"
if not defined INSTALLPATH (
    set "VMWARE_INSTALLED=0"
    echo VMware is not installed
) else (
    set "VMWARE_INSTALLED=1"
    echo VMware is installed at: "%INSTALLPATH%"
    setlocal EnableDelayedExpansion
    for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v ProductVersion') do set ProductVersion=%%B
    echo VMware product version: !ProductVersion!
    endlocal
)

endlocal & set "INSTALLPATH=%INSTALLPATH%" & set "VMWARE_INSTALLED=%VMWARE_INSTALLED%"
goto :EOF

:: --- Function: Get VMware Tools ---
:get_vmware_tools
echo Getting VMware Tools...
if not exist "gettools.exe" (
    echo ERROR: gettools.exe not found!
    endlocal
    exit /b 1
)
gettools.exe
if errorlevel 1 (
    echo ERROR: gettools.exe failed with errorlevel=%errorlevel%
    endlocal
    exit /b 1
)

endlocal & set "INSTALLPATH=%INSTALLPATH%" & set "VMWARE_INSTALLED=%VMWARE_INSTALLED%"
goto :EOF

:: ----------------------------------------------------------------------
:: Function: Check if VMware Tools files are already present in INSTALLPATH
:: Sets CHECK_INSTALLED=1 if files are found, otherwise 0
:: Echoes status message
:: ----------------------------------------------------------------------
:check_vmware_tools_installed
:: No setlocal - we want CHECK_INSTALLED visible in caller

set "CHECK_INSTALLED=0"

:: Get directory where the script is running
set "SCRIPT_DIR=%~dp0"
:: Remove trailing backslash if present
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "BACKUP_FOLDER=%SCRIPT_DIR%\backup-windows"

echo Checking for backup folder: %BACKUP_FOLDER%

if exist "%BACKUP_FOLDER%" (
    set "CHECK_INSTALLED=1"
    echo.
    echo VMware Tools backup folder found: backup-windows
    echo Appears to be already present/installed.
    echo Skipping instalation.
    echo Run win-uninstall.cmd first to remove tools and restore original files.
    echo.
) else (
    echo No backup-windows folder found in script directory.
    echo Proceeding with installation...
    echo.
)

endlocal & set "CHECK_INSTALLED=%CHECK_INSTALLED%"
goto :EOF

:: --- Function: Copy VMware Tools ---
:copy_vmware_tools
if defined INSTALLPATH (
    xcopy /F /Y .\tools\darwin*.* "%INSTALLPATH%"
    if errorlevel 1 (
        echo ERROR: xcopy failed with errorlevel=%errorlevel%
        endlocal
        exit /b 1
    )
)
echo Finished!

endlocal
goto :EOF

:: --- Function: Stop VMware services ---
:stop_vmware_services
echo Stopping VMware services...
net stop vmware-view-usbd       >NUL 2>&1
net stop VMwareHostd            >NUL 2>&1
net stop VMAuthdService         >NUL 2>&1
net stop VMUSBArbService        >NUL 2>&1
taskkill /F /IM vmware-tray.exe >NUL 2>&1
goto :EOF

:: --- Function: Start VMware services ---
:start_vmware_services
echo Starting VMware services...
net start VMUSBArbService   >NUL 2>&1
net start VMAuthdService    >NUL 2>&1
net start VMwareHostd       >NUL 2>&1
net start vmware-view-usbd  >NUL 2>&1
goto :EOF

:: --- Function: Backup VMware files ---
:backup_vmware_files
echo Backing up files...
rd /s /q .\backup-windows > NUL 2>&1
mkdir .\backup-windows
mkdir .\backup-windows\x64
xcopy /F /Y "%INSTALLPATH%x64\vmware-vmx.exe" .\backup-windows\x64
xcopy /F /Y "%INSTALLPATH%x64\vmware-vmx-debug.exe" .\backup-windows\x64
xcopy /F /Y "%INSTALLPATH%x64\vmware-vmx-stats.exe" .\backup-windows\x64
xcopy /F /Y "%INSTALLPATH%vmwarebase.dll" .\backup-windows\
goto :EOF
