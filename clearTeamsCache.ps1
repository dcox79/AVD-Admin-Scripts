# MS Teams Remediation Script
# This script closes Teams, clears the cache, and restarts the application
# Author: David Cox

# Set confirmation preference to suppress prompts
$ConfirmPreference = 'None'

# 1. Load required assemblies for notifications
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to display desktop notifications
function Show-Notification {
    param (
        [string]$Title,
        [string]$Message
    )
    
    $notification = New-Object System.Windows.Forms.NotifyIcon
    $notification.Icon = [System.Drawing.SystemIcons]::Information
    $notification.BalloonTipTitle = $Title
    $notification.BalloonTipText = $Message
    $notification.Visible = $true
    
    # Show balloon tip
    $notification.ShowBalloonTip(10000)
    
    # Give it time to display
    Start-Sleep -Seconds 3
    
    # Clean up
    $notification.Dispose()
}

# Function to remove items with retry
function Remove-ItemSafely {
    param (
        [string]$Path,
        [int]$MaxAttempts = 3,
        [int]$RetryDelay = 2
    )
    
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            if (Test-Path -Path $Path) {
                if ((Get-Item $Path) -is [System.IO.DirectoryInfo]) {
                    # For directories, try both methods
                    try {
                        # First attempt with basic removal
                        Remove-Item -Path $Path -Recurse -Force -Confirm:$false -ErrorAction Stop
                    } catch {
                        # If that fails, try to clear contents first
                        Get-ChildItem -Path $Path -Recurse -Force | 
                        ForEach-Object {
                            try {
                                Remove-Item -Path $_.FullName -Force -Confirm:$false -ErrorAction Stop
                            } catch {
                                Write-Verbose "Could not remove $($_.FullName): $_"
                            }
                        }
                        # Then try to remove the directory again
                        Remove-Item -Path $Path -Force -Confirm:$false -ErrorAction Stop
                    }
                } else {
                    # For files
                    Remove-Item -Path $Path -Force -Confirm:$false -ErrorAction Stop
                }
                return $true
            }
            return $true  # Path doesn't exist, consider it a success
        } catch {
            if ($attempt -eq $MaxAttempts) {
                Write-Warning "Failed to remove $Path after $MaxAttempts attempts: $_"
                return $false
            }
            Write-Verbose "Attempt $attempt failed, retrying in $RetryDelay seconds..."
            Start-Sleep -Seconds $RetryDelay
        }
    }
}

# 1. Show initial notification
Show-Notification -Title "MS Teams Remediation" -Message "We are working on your reported MS Teams problem. Teams will be closed, cache cleared, and then reopened. Please save any ongoing work in Teams."

# Wait for user to save work
Start-Sleep -Seconds 7

# 2. Close Teams client
$teamsProcesses = Get-Process -Name "*teams*" -ErrorAction SilentlyContinue
if ($teamsProcesses) {
    Write-Output "Closing Teams processes..."
    $teamsProcesses | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    Start-Sleep -Seconds 3
    
    # Force close if still running
    $teamsProcesses = Get-Process -Name "*teams*" -ErrorAction SilentlyContinue
    if ($teamsProcesses) {
        $teamsProcesses | Stop-Process -Force
    }
}

# 3. Delete all data inside the MSTeams_8wekyb3d8bbwe folder
$teamsFolder = Join-Path $env:LOCALAPPDATA "Packages\MSTeams_8wekyb3d8bbwe"
if (Test-Path $teamsFolder) {
    Write-Output "Deleting all data from $teamsFolder..."
    
    try {
        # Get all items and force delete them
        Get-ChildItem -Path $teamsFolder -Force -Recurse | 
        ForEach-Object {
            try {
                if ($_.PSIsContainer) {
                    Remove-Item -Path $_.FullName -Force -Recurse -ErrorAction Stop
                } else {
                    Remove-Item -Path $_.FullName -Force -ErrorAction Stop
                }
            } catch {
                Write-Warning "Could not remove $($_.FullName): $_"
            }
        }
    } catch {
        Write-Warning "Error during cleanup: $_"
    }
}

# Wait a moment for file operations to complete
Start-Sleep -Seconds 3

# 4. Restart Teams
# Start the Microsoft Store version of Teams
try {
    Write-Output "Restarting Teams..."
    Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder\MSTeams_8wekyb3d8bbwe!MSTeams"
    $teamsStarted = $true
} catch {
    $teamsStarted = $false
    Write-Output "Failed to start Microsoft Store Teams: $_"
}

# If that fails, try the classic desktop version as fallback
if (-not $teamsStarted) {
    $teamsDesktopPath = Join-Path $env:LOCALAPPDATA "Microsoft\Teams\current\Teams.exe"
    if (Test-Path $teamsDesktopPath) {
        try {
            Start-Process $teamsDesktopPath
            $teamsStarted = $true
        } catch {
            Write-Output "Failed to start classic Teams: $_"
        }
    }
}

# Allow time for Teams to start
Start-Sleep -Seconds 5

# 5. Alert user that Teams has been restarted
Show-Notification -Title "MS Teams Remediation Complete" -Message "Teams has been restarted. It is now safe to use Teams again. If you continue experiencing issues, please contact the service desk."

Write-Output "Teams remediation script completed."