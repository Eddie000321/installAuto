@echo off
:: ==============================================================
:: File: Test_Trigger_Reinstall.bat
:: Purpose: Sets the file date to 40 days ago to trigger reinstall
:: Run this, then reboot to test the auto-reinstall + reboot flow
:: ==============================================================

:: Check Admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [Requesting Admin Rights...]
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ============================================================
echo  [TEST MODE] Setting conditions to trigger reinstall
echo ============================================================
echo.

:: Set file date to 40 days ago
echo [1/2] Setting san31137.exe date to 40 days ago...
powershell -Command "(Get-Item 'C:\Sandra_Auto\san31137.exe').LastWriteTime = (Get-Date).AddDays(-40)"

:: Verify
echo.
echo [2/2] Verifying...
powershell -Command "(Get-Item 'C:\Sandra_Auto\san31137.exe').LastWriteTime"

echo.
echo ============================================================
echo  [READY] Conditions set for reinstall trigger!
echo ============================================================
echo.
echo  On next reboot, the following will happen:
echo    1. Logic.ps1 detects 40 days passed
echo    2. Sandra will be uninstalled
echo    3. Sandra will be reinstalled
echo    4. Popup notification will appear
echo    5. PC will reboot in 10 seconds
echo.
echo  Press any key to REBOOT NOW and test...
echo  Or close this window to reboot manually later.
echo ============================================================
pause >nul

shutdown /r /t 5 /c "Testing Sandra auto-reinstall..."
