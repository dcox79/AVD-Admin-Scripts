<#
.SYNOPSIS
    Detects registry keys that disable Microsoft Office Protected View features.

.DESCRIPTION
    This script checks the registry for keys that disable Office Protected View features
    across all user profiles. It looks for specific registry keys in Office applications
    like Word and Excel that, when set to 1, disable Protected View for internet files,
    unsafe locations, and Outlook attachments.

.NOTES
    Filename: detectDisabledProtectedOfficeFiles.ps1
    Version: 1.0
    Author: David Cox
    Creation Date: 2025-05-07
#>

# Exit codes
# 0 = Compliant (no disabled protected view settings found)
# 1 = Non-compliant (disabled protected view settings found)

# Define the registry paths and values to check
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

# Initialize an array to store findings
$findings = @()

# Function to map Office version number to name
$officeVersionMap = @{
    "12.0" = "2007"
    "14.0" = "2010"
    "15.0" = "2013"
    "16.0" = "2016/2019/365"
}

Write-Output "[DEBUG] Checking HKCU for current user: $env:USERDOMAIN\$env:USERNAME"
# --- Check HKCU for current user (in addition to all HKU SIDs) ---
foreach ($version in $officeVersions) {
    $officeName = $officeVersionMap[$version]
    foreach ($app in $protectedViewSettings.Keys) {
        foreach ($setting in $protectedViewSettings[$app]) {
            $regPath = "HKCU:\Software\Microsoft\Office\$version\$app\Security\ProtectedView"
            try {
                Write-Output "[DEBUG] Checking path: $regPath for setting: $setting"
                if (Test-Path $regPath) {
                    $value = Get-ItemProperty -Path $regPath -Name $setting -ErrorAction SilentlyContinue
                    Write-Output "[DEBUG] Found $setting, value: $($value.$setting)"
                    if ($null -ne $value -and $value.$setting -eq 1) {
                        $findings += [PSCustomObject]@{
                            SID = $env:USERDOMAIN + '\' + $env:USERNAME
                            Username = $env:USERDOMAIN + '\' + $env:USERNAME
                            RegistryKey = "$regPath\$setting = 1"
                            Description = "$app in Microsoft Office $officeName has protected view $(
                                switch ($setting) {
                                    "DisableInternetFilesInPV" { "from files originating from the internet" }
                                    "DisableUnsafeLocationsInPV" { "from files located from potentially unsafe locations" }
                                    "DisableAttachmentsInPV" { "for Outlook attachments" }
                                }
                            ) disabled. (Current User)"
                        }
                    }
                }
            } catch { continue }
        }
    }
}

# --- Check each user's registry for disabled protected view settings (HKU) ---
foreach ($sid in $userSIDs) {
    Write-Output "[DEBUG] Checking HKU SID: $sid"
    # Get username for the SID if possible
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
                    Write-Output "[DEBUG] Checking path: $regPath for setting: $setting"
                    if (Test-Path $regPath) {
                        $value = Get-ItemProperty -Path $regPath -Name $setting -ErrorAction SilentlyContinue
                        Write-Output "[DEBUG] Found $setting, value: $($value.$setting)"
                        
                        if ($null -ne $value -and $value.$setting -eq 1) {
                            # Add finding to the array
                            $findings += [PSCustomObject]@{
                                SID = $sid
                                Username = $username
                                RegistryKey = "HKU\$sid\Software\Microsoft\Office\$version\$app\Security\ProtectedView\$setting = 1"
                                Description = "$app in Microsoft Office $officeName has protected view $(
                                    switch ($setting) {
                                        "DisableInternetFilesInPV" { "from files originating from the internet" }
                                        "DisableUnsafeLocationsInPV" { "from files located from potentially unsafe locations" }
                                        "DisableAttachmentsInPV" { "for Outlook attachments" }
                                    }
                                ) disabled."
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

# Output findings if any were found
if ($findings.Count -gt 0) {
    foreach ($finding in $findings) {
        if (-not [string]::IsNullOrEmpty($finding.Username)) {
            Write-Output "SID              : $($finding.SID)"
            Write-Output "Username         : $($finding.Username)"
        }
        Write-Output "Registry Key     : $($finding.RegistryKey)"
        Write-Output "This application : $($finding.Description)"
        Write-Output ""
    }
    
    # Exit with code 1 to indicate non-compliance
    exit 1
} else {
    # No issues found, exit with code 0 to indicate compliance
    Write-Output "No disabled Office Protected View settings were found."
    exit 0
}