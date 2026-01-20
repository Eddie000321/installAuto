@echo off
setlocal
echo [SiSoftware Sandra Auto-Reinstaller]
echo.

:: 1. Uninstall the existing version (Requires Admin Rights)
echo [1/3] Safely uninstalling the existing version...

:: Define the uninstaller path (Check the exact path for your version)
set "UNINSTALLER=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021\unins000.exe"

:: Check if the uninstaller exists
if exist "%UNINSTALLER%" (
    :: /VERYSILENT : No progress window
    :: /SUPPRESSMSGBOXES : No warning/confirmation boxes
    :: /NORESTART : Prevent forced reboot
    "%UNINSTALLER%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    echo  -> Uninstall command sent. Waiting for completion...
    timeout /t 10 /nobreak >nul
) else (
    echo  -> Existing installation not found (or path is different).
)

:: 2. Clean up residual files (Optional)
echo [2/3] Cleaning up residual folders...
:: Give the system a moment to unload drivers
timeout /t 3 /nobreak >nul
if exist "%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021" (
    rmdir /s /q "%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021"
)

:: 3. Install the new version
echo [3/3] Installing the new version from USB...

:: IMPORTANT: Change 'san2021.exe' to your actual installer filename
if exist "%~dp0san2021.exe" (
    :: /S or /VERYSILENT depends on the installer type. usually /S works.
    "%~dp0san2021.exe" /S
    echo  -> Installation complete.
) else (
    echo  -> ERROR: Installer file (san2021.exe) not found on USB.
)

echo.
echo All tasks finished.
pause