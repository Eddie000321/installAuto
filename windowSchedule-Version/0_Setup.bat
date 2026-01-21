@echo off
:: ==============================================================
:: File: 0_Setup.bat
:: Purpose: Initial setup - Creates folder, copies files, registers scheduler
:: This is the ONLY file you need to run from the USB
:: ==============================================================

:: 1. Check for Admin Rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ========================================================
    echo [ADMIN RIGHTS REQUIRED]
    echo Right-click and select 'Run as administrator'
    echo ========================================================
    pause
    exit /b
)

echo.
echo ============================================================
echo  [Sandra Auto-Reset System] Installing to PC...
echo ============================================================
echo.

:: 2. Create Target Folder (C:\Sandra_Auto)
set "TARGET_DIR=C:\Sandra_Auto"
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo [OK] Created folder: %TARGET_DIR%
) else (
    echo [OK] Folder already exists: %TARGET_DIR%
)

:: 3. Copy Files (USB -> PC)
echo.
echo [1/2] Copying files...
copy "%~dp0san31137.exe" "%TARGET_DIR%\" /Y >nul
copy "%~dp0Logic.ps1" "%TARGET_DIR%\" /Y >nul

:: Verify files were copied
if not exist "%TARGET_DIR%\san31137.exe" (
    echo.
    echo [ERROR] Installer file (san31137.exe) was not copied!
    echo Make sure all 3 files are in the USB folder:
    echo   - san31137.exe
    echo   - Logic.ps1
    echo   - 0_Setup.bat
    pause
    exit /b
)

if not exist "%TARGET_DIR%\Logic.ps1" (
    echo.
    echo [ERROR] Logic file (Logic.ps1) was not copied!
    pause
    exit /b
)

echo [OK] Files copied successfully.

:: 4. Register Windows Task Scheduler
echo.
echo [2/2] Registering scheduled task...

:: Delete existing task (prevent duplicates)
schtasks /delete /tn "Sandra_Auto_Reset" /f >nul 2>&1

:: Create new task (Trigger: ONSTART - runs every boot)
schtasks /create /tn "Sandra_Auto_Reset" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%TARGET_DIR%\Logic.ps1\"" /sc ONSTART /ru SYSTEM /rl HIGHEST /f

if %errorlevel% equ 0 (
    echo [OK] Scheduled task registered successfully.
    echo.
    echo ============================================================
    echo  [SUCCESS] Setup Complete!
    echo ============================================================
    echo.
    echo  This PC will now automatically:
    echo    - Check the date every time it boots
    echo    - Reinstall Sandra if 30 days have passed
    echo    - Run silently in the background
    echo.
    echo  You can safely remove the USB drive now.
    echo ============================================================
) else (
    echo.
    echo [FAILED] Could not register scheduled task.
    echo Please check Windows Task Scheduler permissions.
)

echo.
echo Window will close in 5 seconds...
timeout /t 5 /nobreak >nul
