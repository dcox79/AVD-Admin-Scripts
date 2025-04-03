# Author: David Cox
# Date: 11/11/2024
# This script adds the HRCheck printer to the machine.
# Designed for Intune remediation.

# Define the printer path - this should be updated with your organization's printer path
$printerPath = "\\sterling1.sbt.local\HRCheck"

try {
    # Check if printer is already installed
    $printer = Get-Printer -Name "HRCheck" -ErrorAction SilentlyContinue
    if ($printer) {
        Write-Output "HRCheck printer is already installed."
        exit 0  # Compliant
    }

    # Install the printer
    Add-Printer -ConnectionName $printerPath
    Write-Output "HRCheck printer installed successfully."
    exit 0  # Compliant
} catch {
    Write-Error "Failed to install HRCheck printer: $_"
    exit 1  # Non-Compliant
}
