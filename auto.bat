@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: [1] Self-Elevation Routine (Auto-Request Admin Rights)
:: ============================================================
:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
echo.
echo **************************************************
echo Requesting Administrative Privileges...
echo Please click "Yes" in the popup window.
echo **************************************************

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
:: Create VBS script to relaunch this batch file as Admin
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPriv_v1.vbs"
echo UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPriv_v1.vbs"
"%temp%\OEgetPriv_v1.vbs"
exit /B

:gotPrivileges
:: ============================================================
:: [2] Main Logic (Runs as Administrator)
:: ============================================================

:: IMPORTANT: Switch working directory back to the USB (current folder)
cd /d "%~dp0"

echo.
echo [1/3] Force closing running Sandra processes...
taskkill /F /IM Sandra.exe >nul 2>&1
taskkill /F /IM RpcSandbox.exe >nul 2>&1
taskkill /F /IM W32Sandra.exe >nul 2>&1
echo Done.

:: --- Find the Uninstaller ---
echo [2/3] Locating and running uninstaller...

set "TARGET_DIR=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021"
set "UNINS=%TARGET_DIR%\unins000.exe"

:: Fallback check if the folder name is different (without 2021)
if not exist "%UNINS%" (
    set "TARGET_DIR=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite"
    set "UNINS=!TARGET_DIR!\unins000.exe"
)

:: Run Uninstaller if found
if exist "%UNINS%" (
    echo Found Uninstaller: "%UNINS%"
    echo Uninstalling... Please wait.
    :: start /wait ensures we don't proceed until uninstall is done
    start /wait "" "%UNINS%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    echo Uninstall complete.
) else (
    echo Uninstaller not found (Program might already be removed).
)

:: --- Cleanup Residual Files ---
echo Cleaning up residual folders...
timeout /t 3 /nobreak >nul
if exist "!TARGET_DIR!" (
    rmdir /s /q "!TARGET_DIR!"
)

:: --- Install New Version ---
echo.
echo [3/3] Installing new version (san31137.exe)...

if exist "san31137.exe" (
    start /wait "" "san31137.exe" /VERYSILENT /SUPPRESSMSGBOXES
    echo Installation Complete!
) else (
    echo.
    echo [ERROR] File 'san31137.exe' NOT found in this folder.
    echo Please check your USB drive.
)

:: ============================================================
:: [3] End of Script - Wait for User Input
:: ============================================================
echo.
echo ========================================================
echo  All tasks finished successfully.
echo  Press ENTER to close this window...
echo ========================================================
pause >nul
exit