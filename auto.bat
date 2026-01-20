@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

:: ============================================================
:: [1] Check for Admin Rights & Self-Elevate (Using PowerShell)
:: ============================================================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo.
    echo [Administrator Privileges Required]
    echo You do not have admin rights. Requesting permission...
    echo Please click "Yes" in the popup window.
    echo.
    
    :: Use PowerShell to restart this script as Administrator
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    
    :: Wait for 5 seconds so you can see the message before this window closes
    echo [Info] Waiting for the new Admin window to open...
    timeout /t 5 >nul
    exit /b
)

:: ============================================================
:: [2] This part runs ONLY in the new Admin Window
:: ============================================================
:: IMPORTANT: Return to the USB folder path
cd /d "%~dp0"

echo.
echo ========================================================
echo  Admin privileges acquired! Starting the process...
echo ========================================================
echo.

:: --- 1. Force Close Running Processes ---
echo [1/3] Force closing running programs...
taskkill /F /IM Sandra.exe >nul 2>&1
taskkill /F /IM RpcSandbox.exe >nul 2>&1
taskkill /F /IM W32Sandra.exe >nul 2>&1
echo Done.

:: --- 2. Find and Run Uninstaller ---
echo.
echo [2/3] Searching for uninstaller (unins000.exe)...

set "TARGET_DIR=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021"
set "UNINS=%TARGET_DIR%\unins000.exe"

:: Fallback check if the folder name is different (without 2021)
if not exist "%UNINS%" (
    set "TARGET_DIR=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite"
    set "UNINS=!TARGET_DIR!\unins000.exe"
)

:: Run Uninstaller if found
if exist "%UNINS%" (
    echo Found: "%UNINS%"
    echo Uninstalling... (This may take a moment)
    start /wait "" "%UNINS%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    echo Uninstall complete.
) else (
    echo [WARNING] Uninstaller not found. (Already removed?)
)

:: Cleanup Residual Folders
echo Cleaning up residual files...
timeout /t 2 /nobreak >nul
if exist "!TARGET_DIR!" (
    rmdir /s /q "!TARGET_DIR!"
)

:: --- 3. Install New Version ---
echo.
echo [3/3] Installing new version (san31137.exe)...

if exist "san31137.exe" (
    start /wait "" "san31137.exe" /VERYSILENT /SUPPRESSMSGBOXES
    echo Installation finished successfully!
) else (
    echo.
    echo [ERROR] File 'san31137.exe' not found on USB.
    echo Please check the filename.
)

:: ============================================================
:: [3] Prevent Auto-Close (Wait for Enter)
:: ============================================================
echo.
echo ========================================================
echo  All tasks finished.
echo  Press ENTER to close this window.
echo ========================================================
pause >nul