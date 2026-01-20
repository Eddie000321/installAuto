@echo off
setlocal
echo [SiSoftware Sandra Auto-Reinstaller]
echo.

:: 1. Uninstall the existing version (Requires Admin Rights)
echo [1/3] Safely uninstalling the existing version...

:: Define the uninstaller path (Standard path for Lite 2021)
set "UNINSTALLER=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021\unins000.exe"

:: Check if the uninstaller exists
if exist "%UNINSTALLER%" (
    :: /VERYSILENT : No progress window
    :: /SUPPRESSMSGBOXES : No warning/confirmation boxes
    :: /NORESTART : Prevent forced reboot
    "%UNINSTALLER%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    echo  -> Uninstall command sent. Waiting for completion...
    timeout /t 15 /nobreak >nul
) else (
    echo  -> Existing installation not found (or path is different).
)

:: 2. Clean up residual files
echo [2/3] Cleaning up residual folders...
timeout /t 3 /nobreak >nul
if exist "%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021" (
    rmdir /s /q "%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021"
)

:: 3. Install the new version
echo [3/3] Installing the new version (san31137)...

:: UPDATED: Filename changed to san31137.exe
if exist "%~dp0san31137.exe" (
    :: /VERYSILENT /SUPPRESSMSGBOXES used for silent install
    "%~dp0san31137.exe" /VERYSILENT /SUPPRESSMSGBOXES
    echo  -> Installation complete.
) else (
    echo  -> ERROR: Installer file 'san31137.exe' not found on USB.
    echo     Please check if the file is named correctly.
)

echo.
echo All tasks finished.
pause