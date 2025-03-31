# Author: Dave Cox
# Date: 11/11/2024
# This script adds the HRCheck printer to the machine.

$printerPath = "\\sterling1.sbt.local\HRCheck"
try {
    Add-Printer -ConnectionName $printerPath
    Write-Host "HRCheck printer installed successfully."
    exit 0
} catch {
    Write-Error "Failed to install HRCheck printer."
    exit 1
}
