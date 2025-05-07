# Detection script to check if Company Portal is installed
$applicationName = "Company Portal"
$installedApps = Get-AppxPackage | Where-Object { $_.Name -eq "Microsoft.CompanyPortal" }

if ($installedApps) {
    Write-Output "$applicationName is installed."
    exit 0
} else {
    Write-Output "$applicationName is not installed."
    exit 1
}
