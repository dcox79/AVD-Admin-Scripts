# Check for Zoom installation in both machine-wide and current user registries
$zoomMachinePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
$zoomUserPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Function to search for Zoom in registry paths
function Test-ZoomInstalled {
    param (
        [string]$path
    )
    $installedApps = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue
    foreach ($app in $installedApps) {
        if ($app.DisplayName -like "*Zoom*") {
            Write-Output "Zoom is installed."
            exit 1
        }
    }
}

# Check machine-wide installations
Test-ZoomInstalled -path $zoomMachinePath

# Check current user installations
Test-ZoomInstalled -path $zoomUserPath

Write-Output "Zoom is not installed."
exit 0