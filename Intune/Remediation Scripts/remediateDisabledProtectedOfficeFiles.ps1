<#
.SYNOPSIS
    Remediates registry keys that disable Microsoft Office Protected View features.

.DESCRIPTION
    This script fixes registry settings that disable Office Protected View features
    across all user profiles. It looks for specific registry keys in Office applications
    like Word and Excel that, when set to 1, disable Protected View for internet files,
    unsafe locations, and Outlook attachments, and sets them back to 0 (enabled).

.NOTES
    Filename: remediateDisabledProtectedOfficeFiles.ps1
    Version: 1.0
    Author: David Cox
    Creation Date: 2025-05-07
#>

# Exit codes
# 0 = Remediation successful
# 1 = Remediation failed

# Define the registry paths and values to check and remediate
$protectedViewSettings = @{
    "Excel" = @("DisableInternetFilesInPV", "DisableUnsafeLocationsInPV", "DisableAttachmentsInPV")
    "Word" = @("DisableInternetFilesInPV", "DisableUnsafeLocationsInPV", "DisableAttachmentsInPV")
    "PowerPoint" = @("DisableInternetFilesInPV", "DisableUnsafeLocationsInPV", "DisableAttachmentsInPV")
}

# Office versions to check (12.0 = 2007, 14.0 = 2010, 15.0 = 2013, 16.0 = 2016/2019/365)
$officeVersions = @("12.0", "14.0", "15.0", "16.0")

# Get all user SIDs from the registry
$userSIDs = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | 
    Where-Object { $_.PSChildName -match '^S-1-5-21-\d+-\d+-\d+-\d+$' } | 
    Select-Object -ExpandProperty PSChildName

# Add default and system accounts
$userSIDs += ".DEFAULT"
$userSIDs += "S-1-5-18" # Local System
$userSIDs += "S-1-5-19" # Local Service
$userSIDs += "S-1-5-20" # Network Service

# Initialize counters
$remediatedCount = 0
$errorCount = 0

# Function to map Office version number to name (for logging)
$officeVersionMap = @{
    "12.0" = "2007"
    "14.0" = "2010"
    "15.0" = "2013"
    "16.0" = "2016/2019/365"
}

# Check and remediate each user's registry for disabled protected view settings
foreach ($sid in $userSIDs) {
    # Get username for the SID if possible (for logging)
    $username = $null
    if ($sid -ne ".DEFAULT" -and $sid -ne "S-1-5-18" -and $sid -ne "S-1-5-19" -and $sid -ne "S-1-5-20") {
        try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
            $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
            $username = $objUser.Value
        } catch {
            $username = "Unknown User"
        }
    } else {
        $username = switch ($sid) {
            ".DEFAULT" { "Default User Profile" }
            "S-1-5-18" { "SYSTEM" }
            "S-1-5-19" { "LOCAL SERVICE" }
            "S-1-5-20" { "NETWORK SERVICE" }
        }
    }
    
    # Check each Office version
    foreach ($version in $officeVersions) {
        $officeName = $officeVersionMap[$version]
        
        # Check each application
        foreach ($app in $protectedViewSettings.Keys) {
            # Check each protected view setting
            foreach ($setting in $protectedViewSettings[$app]) {
                $regPath = "HKU:\$sid\Software\Microsoft\Office\$version\$app\Security\ProtectedView"
                
                # Check if the registry key exists and is set to 1
                try {
                    if (Test-Path $regPath) {
                        $value = Get-ItemProperty -Path $regPath -Name $setting -ErrorAction SilentlyContinue
                        
                        if ($null -ne $value -and $value.$setting -eq 1) {
                            # Remediate by setting the value to 0
                            try {
                                Set-ItemProperty -Path $regPath -Name $setting -Value 0 -Type DWORD -Force
                                $remediatedCount++
                                
                                # Log the remediation
                                $settingDescription = switch ($setting) {
                                    "DisableInternetFilesInPV" { "from files originating from the internet" }
                                    "DisableUnsafeLocationsInPV" { "from files located from potentially unsafe locations" }
                                    "DisableAttachmentsInPV" { "for Outlook attachments" }
                                }
                                
                                Write-Output "Remediated: $app in Microsoft Office $officeName - Protected view $settingDescription has been enabled for $username (SID: $sid)"
                            } catch {
                                $errorCount++
                                Write-Error "Failed to remediate $app Protected View setting ($setting) for $username (SID: $sid): $_"
                            }
                        }
                    }
                } catch {
                    # Continue to next setting if there's an error
                    continue
                }
            }
        }
    }
}

# Output summary
Write-Output "\nRemediation Summary:"
Write-Output "Settings remediated: $remediatedCount"
Write-Output "Errors encountered: $errorCount"

# Return appropriate exit code
if ($errorCount -eq 0) {
    if ($remediatedCount -gt 0) {
        Write-Output "\nRemediation completed successfully."
    } else {
        Write-Output "\nNo settings required remediation."
    }
    exit 0
} else {
    Write-Output "\nRemediation completed with errors."
    exit 1
}