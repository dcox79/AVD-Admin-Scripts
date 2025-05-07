<#
.SYNOPSIS
    Enables NumLock at startup for all users.
.DESCRIPTION
    This script is designed as an Intune remediation script to enable NumLock at startup for all users.
    It modifies the registry settings for the default user profile and attempts to enable NumLock immediately.
    
    Exit Codes:
    0 - Compliant (NumLock is enabled)
    1 - Non-Compliant (NumLock is not enabled or error occurred)
.NOTES
    Version: 1.3
    Author: David Cox
#>

# Function to check if NumLock is enabled in the registry
function Test-NumLockEnabled {
    $defaultUserPath = 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard'
    try {
        $value = Get-ItemProperty -Path $defaultUserPath -Name "InitialKeyboardIndicators" -ErrorAction Stop
        if ($value.InitialKeyboardIndicators -eq "2") {
            Write-Output "NumLock is enabled in registry."
            return $true
        } else {
            Write-Output "NumLock is not enabled in registry. Current value: $($value.InitialKeyboardIndicators)"
            return $false
        }
    } catch {
        Write-Warning "Failed to read registry: $_"
        return $false
    }
}

# Function to enable NumLock
function Enable-NumLock {
    try {
        # Attempt to set NumLock on for the default user (affects new user profiles)
        $defaultUserPath = 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard'
        
        # Ensure the registry key exists
        if (-not (Test-Path $defaultUserPath)) {
            Write-Output "Creating registry key path..."
            New-Item -Path $defaultUserPath -Force | Out-Null
        }
        
        # Try using Set-ItemProperty with -Force parameter
        Write-Output "Setting registry value..."
        Set-ItemProperty -Path $defaultUserPath -Name "InitialKeyboardIndicators" -Value "2" -Force -ErrorAction Stop

        # Attempt to enable NumLock using WScript.Shell (may not work in system context)
        try {
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{NUMLOCK}')
            Write-Output "NumLock toggled successfully."
        } catch {
            Write-Warning "Unable to toggle NumLock immediately. It will be enabled on next login."
        }

        # Verify the change
        if (Test-NumLockEnabled) {
            Write-Output "NumLock at startup successfully enabled for all users."
            return $true
        } else {
            Write-Error "Failed to verify registry change."
            return $false
        }
    } catch {
        Write-Warning "Unable to set registry key directly. Attempting alternative method..."
        
        try {
            # Alternative method using reg.exe
            Write-Output "Attempting registry modification using reg.exe..."
            $result = & reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f
            
            if ($LASTEXITCODE -eq 0) {
                if (Test-NumLockEnabled) {
                    Write-Output "NumLock enabled using alternative method."
                    return $true
                }
            }
            Write-Error "reg.exe command failed with exit code $LASTEXITCODE"
            return $false
        } catch {
            Write-Error "Error enabling NumLock at startup: $_"
            return $false
        }
    }
}

# Main script logic
try {
    # Ensure we're running with admin privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "This script requires administrative privileges to modify registry settings."
        exit 1  # Failure - Non-Compliant
    }

    if (Test-NumLockEnabled) {
        Write-Output "NumLock is already enabled at startup."
        exit 0  # Success - Compliant
    } else {
        Write-Output "NumLock is not enabled. Attempting to enable..."
        $result = Enable-NumLock
        if ($result) {
            exit 0  # Success - Compliant
        } else {
            exit 1  # Failure - Non-Compliant
        }
    }
} catch {
    Write-Error "Unexpected error: $_"
    exit 1  # Failure - Non-Compliant
}
