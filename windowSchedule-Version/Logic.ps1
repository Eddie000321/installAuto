# File: Logic.ps1
# [FINAL VERSION] 30-Day Smart Reinstall Logic
# DUAL CHECK: Uses BOTH file modification date AND date file for maximum reliability

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
# [1.5] Prevent Duplicate Execution (System Mutex)
# ============================================================
$MutexName = "Global\Sandra_Auto_Reset_Mutex"
$Mutex = $null
$MutexAcquired = $false

try {
    $Mutex = New-Object System.Threading.Mutex($false, $MutexName)
    
    # Try to acquire mutex (wait 0 seconds = immediate check)
    $MutexAcquired = $Mutex.WaitOne(0)
    
    if (-not $MutexAcquired) {
        # Another instance is running, exit silently
        Write-Log "Another instance already running. Exiting."
        exit
    }
} catch {
    # Mutex already exists and owned by another process
    Write-Log "Mutex check failed. Exiting."
    exit
}

# Wrap entire script in try-finally to ensure mutex release
try {

# ============================================================
# [2] DUAL Date Check (30 Days)
# ============================================================
$DoAction = $false
$Today = Get-Date
$Reason = ""

# --- Method 1: Check file modification date ---
if (Test-Path $SetupFile) {
    $FileDate = (Get-Item $SetupFile).LastWriteTime
    $FileDiff = ($Today - $FileDate).Days
    Write-Log "File check: Modified $FileDiff days ago"
    
    if ($FileDiff -ge 30) {
        $DoAction = $true
        $Reason = "File modification date: $FileDiff days"
    }
} else {
    Write-Log "[ERROR] Installer file not found: $SetupFile"
    exit
}

# --- Method 2: Check date file (backup method) ---
if (Test-Path $DateFile) {
    try {
        $LastDate = [datetime]::ParseExact((Get-Content $DateFile), "yyyy-MM-dd", $null)
        $DateDiff = ($Today - $LastDate).Days
        Write-Log "Date file check: $DateDiff days since last record"
        
        if ($DateDiff -ge 30) {
            $DoAction = $true
            $Reason = "Date file record: $DateDiff days"
        }
    } catch {
        Write-Log "Date file corrupted. Using file date only."
    }
} else {
    Write-Log "First run detected (no date file)."
    $DoAction = $true
    $Reason = "First run"
}

# --- Decision ---
if (-not $DoAction) {
    # Both checks passed - less than 30 days
    exit
}

Write-Log "Reinstall triggered. Reason: $Reason"

# ============================================================
# [3] Execute Reinstall
# ============================================================

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
Write-Log "Installing new version..."
Start-Process -FilePath $SetupFile -ArgumentList "/SP-", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait

# Wait for installer to fully release file handles
Start-Sleep -Seconds 3

# --- Step 5: Update BOTH date markers ---
Write-Log "Updating date markers..."

# Update file modification date (with retry)
$MaxRetries = 3
$RetryCount = 0
$DateUpdated = $false

while (-not $DateUpdated -and $RetryCount -lt $MaxRetries) {
    try {
        $Now = Get-Date
        (Get-Item $SetupFile).LastWriteTime = $Now
        
        # Verify the update
        $NewDate = (Get-Item $SetupFile).LastWriteTime
        if (($Now - $NewDate).TotalSeconds -lt 5) {
            $DateUpdated = $true
            Write-Log "File date updated successfully: $NewDate"
        }
    } catch {
        $RetryCount++
        Start-Sleep -Seconds 1
    }
}

if (-not $DateUpdated) {
    Write-Log "[WARNING] Could not update file modification date!"
}

# Update date file
$Today.ToString("yyyy-MM-dd") | Set-Content $DateFile

Write-Log "Installation complete. Date markers updated."

# --- Step 6: Automatic Reboot ---
Write-Log "Rebooting in 30 seconds to apply changes..."

# Reboot after 30 seconds (gives user time to see the Windows notification)
# Note: No MessageBox because SYSTEM account runs in a different session
shutdown /r /t 30 /c "Sandra auto-reinstall completed. Rebooting to apply changes..."

} finally {
    # Release mutex
    if ($MutexAcquired -and $Mutex) {
        $Mutex.ReleaseMutex()
        $Mutex.Dispose()
    }
}
