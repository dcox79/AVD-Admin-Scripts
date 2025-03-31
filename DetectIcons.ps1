# Author: Dave Cox
# Date: 11/11/2024
# This script searches for Office shortcuts on the desktop.

# Define the paths to check for Office shortcuts
$commonDesktopPath = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
$userDesktopPath = [System.Environment]::GetFolderPath('Desktop')

# Define a list of Office application names to check for in shortcut names
$officeApps = @("Word", "Excel", "PowerPoint", "Outlook", "OneNote")

# Function to search for Office shortcuts in a given path
function Search-OfficeShortcuts {
    param (
        [string]$Path
    )
    
    Write-Host "Searching in path: $Path"
    $shortcutsFound = @()

    foreach ($app in $officeApps) {
        $searchPattern = "*$app*.lnk"
        Write-Host "  Looking for pattern: $searchPattern"
        $shortcuts = Get-ChildItem -Path $Path -Filter $searchPattern -ErrorAction SilentlyContinue
        if ($shortcuts) {
            Write-Host "    Found shortcuts: $($shortcuts.Name)"
            $shortcutsFound += $shortcuts
        }
    }

    return $shortcutsFound
}

# Search for Office shortcuts in the common and user desktop directories
$commonShortcuts = Search-OfficeShortcuts -Path $commonDesktopPath
$userShortcuts = Search-OfficeShortcuts -Path $userDesktopPath

# Determine the exit code based on whether shortcuts are found
$exitCode = if ($commonShortcuts.Count -gt 0 -or $userShortcuts.Count -gt 0) { 0 } else { 1 }

# Output the results and exit with the determined code
if ($exitCode -eq 0) {
    Write-Host "Office shortcuts found on the desktop(s)."
} else {
    Write-Host "No Office shortcuts found on the desktop(s)."
}

Write-Host "Common shortcuts found: $($commonShortcuts.Count)"
Write-Host "User shortcuts found: $($userShortcuts.Count)"

exit $exitCode
