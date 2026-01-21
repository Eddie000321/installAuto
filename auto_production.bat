@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

:: ============================================================
:: [1] Check Admin Rights (PowerShell Method)
:: ============================================================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo.
    echo [Requesting Admin Rights...]
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ============================================================
:: [2] Main Process (Admin Mode)
:: ============================================================
:: Go to USB Path
cd /d "%~dp0"
echo.
echo ========================================================
echo  Auto Reinstall - Starting...
echo  USB Path: %CD%
echo ========================================================
echo.

:: --- 1. Force Close (Error check) ---
echo [1/3] Attempting to close running programs...
echo.

taskkill /F /IM Sandra.exe >nul 2>&1
taskkill /F /IM RpcSandbox.exe >nul 2>&1
taskkill /F /IM W32Sandra.exe >nul 2>&1

echo --------------------------------------------------------
echo Step 1 Finished. Proceeding to Uninstall...
echo --------------------------------------------------------
timeout /t 2 /nobreak >nul

:: --- 2. Uninstall ---
echo.
echo [2/3] Searching for uninstaller...

set "TARGET_DIR=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite 2021"
set "UNINS=%TARGET_DIR%\unins000.exe"

if not exist "%UNINS%" (
    set "TARGET_DIR=%ProgramFiles%\SiSoftware\SiSoftware Sandra Lite"
    set "UNINS=!TARGET_DIR!\unins000.exe"
)

if exist "%UNINS%" (
    echo Found: "%UNINS%"
    echo Uninstalling...
    start /wait "" "%UNINS%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    echo Uninstall complete.
) else (
    echo [WARNING] Uninstaller NOT found.
    echo Expected path: %UNINS%
)

echo.
echo --------------------------------------------------------
echo Step 2 Finished. Proceeding to Install...
echo --------------------------------------------------------
timeout /t 2 /nobreak >nul

:: Residual Cleanup
if exist "!TARGET_DIR!" rmdir /s /q "!TARGET_DIR!"

:: --- 3. Install ---
echo.
echo [3/3] Installing san31137.exe...

if exist "san31137.exe" (
    start /wait "" "san31137.exe" /VERYSILENT /SUPPRESSMSGBOXES
    echo Installation Success!
) else (
    echo.
    echo [CRITICAL ERROR] File 'san31137.exe' not found!
    echo Current folder is: %CD%
    echo Please make sure the .exe file is in this folder.
)

echo.
echo ========================================================
echo  All Done! Script completed successfully.
echo  Window will close in 5 seconds...
echo ========================================================
timeout /t 5 /nobreak >nul
