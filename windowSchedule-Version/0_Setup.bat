@echo off
setlocal EnableDelayedExpansion

:: ==============================================================
:: File: 0_Setup.bat
:: Purpose: Initial setup - Creates folder, copies files, registers scheduler
:: This is the ONLY file you need to run from the USB
:: ==============================================================

:: 1. Check Admin Rights and Auto-Elevate
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo.
    echo [Requesting Admin Rights...]
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ============================================================
:: MAIN PROCESS (Admin Mode)
:: ============================================================

:: CRITICAL: Reset to script's original directory after elevation
cd /d "%~dp0"

echo.
echo ============================================================
echo  [Sandra Auto-Reset System] Installing to PC...
echo ============================================================
echo.
echo  Script Location: %~dp0
echo  Current Directory: %CD%
echo.
echo ============================================================

:: Check if source files exist on USB
echo.
echo [Step 0] Checking USB files...
echo ------------------------------------------------------------

if exist "%~dp0san31137.exe" (
    echo   [OK] san31137.exe found on USB
) else (
    echo   [MISSING] san31137.exe NOT found on USB!
)

if exist "%~dp0Logic.ps1" (
    echo   [OK] Logic.ps1 found on USB
) else (
    echo   [MISSING] Logic.ps1 NOT found on USB!
)

:: 2. Create Target Folder (C:\Sandra_Auto)
echo.
echo [Step 1] Creating target folder...
echo ------------------------------------------------------------

set "TARGET_DIR=C:\Sandra_Auto"
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo   [OK] Created folder: %TARGET_DIR%
) else (
    echo   [OK] Folder already exists: %TARGET_DIR%
)

:: 3. Copy Files (USB -> PC)
echo.
echo [Step 2] Copying files from USB to PC...
echo ------------------------------------------------------------

echo   Copying san31137.exe...
copy "%~dp0san31137.exe" "%TARGET_DIR%\" /Y
echo   Copying Logic.ps1...
copy "%~dp0Logic.ps1" "%TARGET_DIR%\" /Y

:: Verify files were copied
echo.
echo [Step 3] Verifying copied files...
echo ------------------------------------------------------------

if exist "%TARGET_DIR%\san31137.exe" (
    echo   [OK] san31137.exe copied successfully
) else (
    echo   [FAILED] san31137.exe was NOT copied!
    echo.
    echo   Possible causes:
    echo     - File missing from USB
    echo     - USB disconnected
    echo     - Permission denied
    echo.
    pause
    exit /b
)

if exist "%TARGET_DIR%\Logic.ps1" (
    echo   [OK] Logic.ps1 copied successfully
) else (
    echo   [FAILED] Logic.ps1 was NOT copied!
    pause
    exit /b
)

:: 4. Register Windows Task Scheduler
echo.
echo [Step 4] Registering scheduled task...
echo ------------------------------------------------------------

:: Delete existing task (prevent duplicates)
echo   Removing old task (if exists)...
schtasks /delete /tn "Sandra_Auto_Reset" /f >nul 2>&1

:: Create new task with DUAL triggers (ONSTART + ONLOGON) using PowerShell
echo   Creating new task with dual triggers...
echo     - Trigger 1: At system startup (with 1 min delay)
echo     - Trigger 2: At user logon
echo.

powershell -ExecutionPolicy Bypass -Command "$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden -File \"C:\Sandra_Auto\Logic.ps1\"'; $Trigger1 = New-ScheduledTaskTrigger -AtStartup; $Trigger1.Delay = 'PT1M'; $Trigger2 = New-ScheduledTaskTrigger -AtLogOn; $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable; $Principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest -LogonType ServiceAccount; Register-ScheduledTask -TaskName 'Sandra_Auto_Reset' -Action $Action -Trigger $Trigger1,$Trigger2 -Settings $Settings -Principal $Principal -Force"

:: Capture result immediately (before any other command changes it)
set "TASK_RESULT=!errorlevel!"

if "!TASK_RESULT!"=="0" (
    echo   [OK] Task registered successfully
    echo.
    echo ============================================================
    echo  [SUCCESS] Setup Complete!
    echo ============================================================
    echo.
    echo  Installed files:
    echo    - C:\Sandra_Auto\san31137.exe
    echo    - C:\Sandra_Auto\Logic.ps1
    echo.
    echo  Scheduled task: Sandra_Auto_Reset (runs at every boot)
    echo.
    echo  This PC will now automatically:
    echo    - Check the date every time it boots
    echo    - Reinstall Sandra if 30 days have passed
    echo    - Run silently in the background
    echo.
    echo  You can safely remove the USB drive now.
    echo ============================================================
) else (
    echo   [FAILED] Could not register scheduled task.
    echo   Error code: !TASK_RESULT!
    echo   Please check Windows Task Scheduler permissions.
)

echo.
echo Press any key to close this window...
pause >nul
