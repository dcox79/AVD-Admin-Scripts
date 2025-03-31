<#
.SYNOPSIS
    Enables NumLock at startup for all users.
.DESCRIPTION
    This script is designed as an Intune remediation script to enable NumLock at startup for all users.
    It modifies the registry settings for the default user profile and attempts to enable NumLock immediately.
.NOTES
    Version: 1.1
    Author: D.Cox
#>

# Function to check if NumLock is enabled in the registry
function Test-NumLockEnabled {
    $defaultUserPath = 'Registry::HKU\.DEFAULT\Control Panel\Keyboard'
    $value = Get-ItemProperty -Path $defaultUserPath -Name "InitialKeyboardIndicators" -ErrorAction SilentlyContinue
    return ($value.InitialKeyboardIndicators -eq 2)
}

# Function to enable NumLock
function Enable-NumLock {
    try {
        # Attempt to set NumLock on for the default user (affects new user profiles)
        $defaultUserPath = 'Registry::HKU\.DEFAULT\Control Panel\Keyboard'
        
        # Try using Set-ItemProperty with -Force parameter
        Set-ItemProperty -Path $defaultUserPath -Name "InitialKeyboardIndicators" -Value "2" -Force -ErrorAction Stop

        # Attempt to enable NumLock using WScript.Shell (may not work in system context)
        try {
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{NUMLOCK}')
        } catch {
            Write-Output "Unable to toggle NumLock immediately. It will be enabled on next login."
        }

        Write-Output "NumLock at startup successfully enabled for all users."
        exit 0  # Success
    } catch {
        Write-Output "Unable to set registry key directly. Attempting alternative method..."
        
        try {
            # Alternative method using reg.exe
            $regCommand = "reg add `"HKU\.DEFAULT\Control Panel\Keyboard`" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f"
            $result = Invoke-Expression $regCommand
            
            if ($LASTEXITCODE -ne 0) {
                throw "reg.exe command failed with exit code $LASTEXITCODE"
            }
        } catch {
            Write-Error "Error enabling NumLock at startup: $_"
            exit 1  # Failure
        }
    }
}

# Main script logic
if (Test-NumLockEnabled) {
    Write-Output "NumLock is already enabled at startup."
    exit 0  # Success, no action needed
} else {
    Enable-NumLock
}
