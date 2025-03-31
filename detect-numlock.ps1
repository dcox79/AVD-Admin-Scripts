<#
.SYNOPSIS
    Detects if NumLock is enabled at startup for all users.
.DESCRIPTION
    This script is designed as an Intune detection script to check if NumLock is enabled at startup for all users.
    It checks the registry settings for the default user profile.
.NOTES
    Version: 1.2
    Author: D.Cox
#>

$registryPath = 'Registry::HKU\.DEFAULT\Control Panel\Keyboard'
$keyName = "InitialKeyboardIndicators"

try {
    $keyValue = Get-ItemProperty -Path $registryPath -Name $keyName -ErrorAction Stop
    
    if ($keyValue.$keyName -eq "2") {
        Write-Output "NumLock at Startup is enabled"
        exit 0  # Compliant
    } else {
        Write-Output "NumLock at Startup is not enabled"
        exit 1  # Non-compliant
    }
} catch {
    Write-Error "Failed to read registry key: $_"
    exit 1  # Non-compliant due to error
}