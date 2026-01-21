# File: Logic.ps1
# [FINAL VERSION] 30-Day Smart Reinstall Logic
# This script runs at every boot and checks if 30 days have passed since last install

# ============================================================
# [1] Configuration
# ============================================================
$BaseDir = "C:\Sandra_Auto"
$SetupFile = Join-Path $BaseDir "san31137.exe"
$DateFile = Join-Path $BaseDir "last_check.txt"
$LogFile = Join-Path $BaseDir "history.log"

function Write-Log { 
    param($Msg) 
    Add-Content $LogFile "[$((Get-Date).ToString('yyyy-MM-dd HH:mm'))] $Msg" 
}

# ============================================================
# [2] Date Calculation (30 Days)
# ============================================================
$DoAction = $false
$Today = Get-Date

if (Test-Path $DateFile) {
    try {
        $LastDate = [datetime]::ParseExact((Get-Content $DateFile), "yyyy-MM-dd", $null)
        $Diff = ($Today - $LastDate).Days
        if ($Diff -ge 30) { 
            Write-Log "Last install was $($Diff) days ago. Starting reinstall."
            $DoAction = $true 
        } else {
            # Less than 30 days - exit silently
            exit
        }
    } catch { 
        # Date file corrupted - force execution
        Write-Log "Date file corrupted. Forcing reinstall."
        $DoAction = $true 
    }
} else {
    Write-Log "First run detected."
    $DoAction = $true
}

# ============================================================
# [3] Execute Reinstall (Only if 30 days passed)
# ============================================================
if ($DoAction) {
    # --- Step 1: Kill running processes ---
    Write-Log "Stopping Sandra processes..."
    Stop-Process -Name "Sandra", "RpcSandbox", "W32Sandra" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    # --- Step 2: Find and run uninstaller ---
    $Path1 = "C:\Program Files\SiSoftware\SiSoftware Sandra Lite 2021\unins000.exe"
    $Path2 = "C:\Program Files\SiSoftware\SiSoftware Sandra Lite\unins000.exe"
    $Uninst = $null

    if (Test-Path $Path1) { $Uninst = $Path1 } 
    elseif (Test-Path $Path2) { $Uninst = $Path2 }

    if ($Uninst) {
        Write-Log "Uninstalling existing version..."
        Start-Process -FilePath $Uninst -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
        Start-Sleep -Seconds 5
    } else {
        Write-Log "No existing installation found. Skipping uninstall."
    }

    # --- Step 3: Clean residual folders ---
    Write-Log "Cleaning residual folders..."
    Remove-Item "C:\Program Files\SiSoftware\SiSoftware Sandra Lite*" -Recurse -Force -ErrorAction SilentlyContinue

    # --- Step 4: Install fresh copy ---
    if (Test-Path $SetupFile) {
        Write-Log "Installing new version..."
        Start-Process -FilePath $SetupFile -ArgumentList "/SP-", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait
        
        # Update date file (stamp today's date)
        $Today.ToString("yyyy-MM-dd") | Set-Content $DateFile
        Write-Log "Installation complete. Date updated."
    } else {
        Write-Log "[ERROR] Installer file not found: $SetupFile"
    }
}
