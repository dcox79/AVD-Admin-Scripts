# Remote Teams Cache Cleaner for Azure Virtual Desktop
# This script can be run remotely to clear a user's Teams cache on AVD session hosts
# Author: David Cox

param (
    [Parameter(Mandatory=$true)]
    [string]$UserName,
    
    [Parameter(Mandatory=$false)]
    [string]$SessionHostName = $env:COMPUTERNAME
)

function Clear-TeamsCache {
    param (
        [string]$UserSID
    )
    
    # Get user profile path from registry
    $userProfilePath = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID" -Name ProfileImagePath | Select-Object -ExpandProperty ProfileImagePath
    
    if (-not $userProfilePath) {
        Write-Error "Could not find profile path for user SID: $UserSID"
        return $false
    }
    
    Write-Output "Found user profile at: $userProfilePath"
    
    # Define Teams paths for this user
    $teamsPackagePath = Join-Path $userProfilePath "AppData\Local\Packages\MSTeams_8wekyb3d8bbwe"
    
    # Check if Teams is running for this user
    $teamsProcesses = Get-Process -Name "*teams*" -IncludeUserName -ErrorAction SilentlyContinue | 
                      Where-Object { $_.UserName -like "*$UserName*" }
    
    if ($teamsProcesses) {
        Write-Output "Closing Teams processes for user $UserName..."
        $teamsProcesses | ForEach-Object { 
            Stop-Process -Id $_.Id -Force
            Write-Output "Stopped process: $($_.ProcessName) (PID: $($_.Id))"
        }
        Start-Sleep -Seconds 3
    }
    
    # Clear Teams cache
    if (Test-Path $teamsPackagePath) {
        Write-Output "Clearing Teams cache at: $teamsPackagePath"
        
        try {
            # Get all items and force delete them
            Get-ChildItem -Path $teamsPackagePath -Force -Recurse | 
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
            
            Write-Output "Teams cache cleared successfully"
            return $true
        } catch {
            Write-Error "Error clearing Teams cache: $_"
            return $false
        }
    } else {
        Write-Warning "Teams package folder not found at: $teamsPackagePath"
        return $false
    }
}

function Restart-TeamsForUser {
    param (
        [string]$UserSID
    )
    
    # Get user profile path
    $userProfilePath = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID" -Name ProfileImagePath | Select-Object -ExpandProperty ProfileImagePath
    
    if (-not $userProfilePath) {
        Write-Error "Could not find profile path for user SID: $UserSID"
        return $false
    }
    
    # Create a scheduled task to run Teams as the user
    $taskName = "RestartTeamsFor_$UserName"
    $action = New-ScheduledTaskAction -Execute "explorer.exe" -Argument "shell:AppsFolder\MSTeams_8wekyb3d8bbwe!MSTeams"
    $principal = New-ScheduledTaskPrincipal -UserId $UserSID
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    
    # Register the task
    Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Settings $settings -Force | Out-Null
    
    # Start the task
    Start-ScheduledTask -TaskName $taskName
    
    # Wait a moment
    Start-Sleep -Seconds 3
    
    # Clean up the task
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    
    Write-Output "Teams has been restarted for user $UserName"
    return $true
}

# Main script execution
Write-Output "Starting Teams cache cleanup for user: $UserName on host: $SessionHostName"

# If running remotely, use Invoke-Command
if ($SessionHostName -ne $env:COMPUTERNAME) {
    Invoke-Command -ComputerName $SessionHostName -ScriptBlock {
        param($UserName)
        
        # Find the user's SID
        $userSID = (New-Object System.Security.Principal.NTAccount($UserName)).Translate([System.Security.Principal.SecurityIdentifier]).Value
        
        if (-not $userSID) {
            Write-Error "Could not find SID for user: $UserName"
            return
        }
        
        # Import functions
        ${function:Clear-TeamsCache} = $using:function:Clear-TeamsCache
        ${function:Restart-TeamsForUser} = $using:function:Restart-TeamsForUser
        
        # Execute the functions
        $cacheCleared = Clear-TeamsCache -UserSID $userSID
        
        if ($cacheCleared) {
            Restart-TeamsForUser -UserSID $userSID
        }
    } -ArgumentList $UserName
} else {
    # Running locally
    # Find the user's SID
    $userSID = (New-Object System.Security.Principal.NTAccount($UserName)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    
    if (-not $userSID) {
        Write-Error "Could not find SID for user: $UserName"
        return
    }
    
    # Execute the functions
    $cacheCleared = Clear-TeamsCache -UserSID $userSID
    
    if ($cacheCleared) {
        Restart-TeamsForUser -UserSID $userSID
    }
}

Write-Output "Teams cache cleanup completed for user: $UserName" 