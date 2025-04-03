# Author: David Cox
# Date: 11/11/2024
# This script checks if the HRCheck printer is installed.

if (Get-Printer -Name "HRCheck" -ErrorAction SilentlyContinue) {
    Write-Host "HRCheck printer is installed."
    exit 0
} else {
    Write-Host "HRCheck printer is not installed."
    exit 1
}
