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
echo  DEBUG MODE START
echo  Current Path: %CD%
echo ========================================================
echo.

:: --- 1. Force Close (Error check) ---
echo [1/3] Attempting to close running programs...
echo (If errors appear below, it is okay. It means the program is not running.)
echo.

:: Remove '>nul' to SEE errors
taskkill /F /IM Sandra.exe 
taskkill /F /IM RpcSandbox.exe 
taskkill /F /IM W32Sandra.exe 

echo.
echo --------------------------------------------------------
echo Step 1 Finished. Check for errors above.
echo Press ENTER to continue to Uninstall...
echo --------------------------------------------------------
pause

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
echo Step 2 Finished. Press ENTER to continue to Install...
echo --------------------------------------------------------
pause

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
echo  Script Finished.
echo  Press ENTER to close.
echo ========================================================
pause