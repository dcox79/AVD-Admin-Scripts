# AVD Administration Scripts

This repository contains PowerShell scripts for managing and troubleshooting Azure Virtual Desktop (AVD) environments, with a focus on common administrative tasks and user experience improvements.

## Scripts Overview

### Teams Management Scripts

#### 1. clearTeamsCache.ps1
A script that runs locally on a user's session to clear the Teams cache.

**Features:**
- Safely closes all Teams processes
- Clears Teams cache files
- Provides user notifications about the process
- Automatically restarts Teams after cleanup
- Handles both Microsoft Store and classic desktop versions of Teams

**Usage:**
```powershell
.\clearTeamsCache.ps1
```

#### 2. RemoteTeamsCacheCleaner.ps1
A script designed for administrators to remotely clear a specific user's Teams cache.

**Usage:**
```powershell
.\RemoteTeamsCacheCleaner.ps1 -UserName "contoso\jsmith"
```

### Service Management Scripts

#### 3. DetectRunningService.ps1
Checks if specified services are running. Useful for monitoring and compliance.

**Usage:**
```powershell
# Edit the $ServicesToCheck array in the script to specify services
.\DetectRunningService.ps1
```

#### 4. KillRunningService.ps1
Forcefully stops specified services and logs the actions to the Windows Event Log.

**Usage:**
```powershell
# Edit the $ServicesToStop array in the script to specify services
.\KillRunningService.ps1
```

#### 5. DetectEnabledServices.ps1
Checks if specified services are enabled and should be disabled. Used for compliance monitoring.

**Usage:**
```powershell
# Edit the $ServicesToDisable array in the script to specify services
.\DetectEnabledServices.ps1
```

#### 6. DisableEnabledScript.ps1
Disables specified services and logs the actions to the Windows Event Log. Works in conjunction with DetectEnabledServices.ps1.

**Usage:**
```powershell
# Edit the $ServicesToDisable array in the script to specify services
.\DisableEnabledScript.ps1
```

### Microsoft 365 Management Scripts

#### 7. Detect-Microsoft365AppsUpdate.ps1
Detects if Microsoft 365 Apps need updates by comparing installed versions against minimum required versions for different update channels.

**Usage:**
```powershell
.\Detect-Microsoft365AppsUpdate.ps1
```

#### 8. Remediate-Microsoft365AppsUpdate.ps1
Remediates Microsoft 365 Apps that need updates by triggering the update process.

**Usage:**
```powershell
.\Remediate-Microsoft365AppsUpdate.ps1
```

### Desktop Environment Scripts

#### 9. AddOfficeIcons.ps1
Creates desktop shortcuts for Microsoft Office applications.

**Features:**
- Creates shortcuts for Word, Excel, PowerPoint, Outlook, OneNote, and Visio
- Handles both 32-bit and 64-bit Office installations
- Verifies successful creation of each shortcut

**Usage:**
```powershell
.\AddOfficeIcons.ps1
```

#### 10. detect-numlock.ps1 and set-numlock.ps1
Scripts to detect and set NumLock state at startup.

**Usage:**
```powershell
# To check NumLock status
.\detect-numlock.ps1

# To enable NumLock at startup
.\set-numlock.ps1
```

#### 11. DetectHRCheck.ps1
Checks if the HRCheck printer is installed on the system.

**Usage:**
```powershell
.\DetectHRCheck.ps1
```

#### 12. DetectIcons.ps1
Scans for Microsoft Office application shortcuts on both the common and user desktops.

**Usage:**
```powershell
.\DetectIcons.ps1
```

#### 13. DetectZoom.ps1
Checks if Zoom is installed on the system by searching both machine-wide and user-specific registry locations.

**Usage:**
```powershell
.\DetectZoom.ps1
```

### Printer Management Scripts

#### 14. AddHRCheck.ps1
Adds the HRCheck network printer to the machine.

**Usage:**
```powershell
.\AddHRCheck.ps1
```

### Authentication Scripts

#### 15. No-MFA.ps1 and No-MSAuth.ps1
Scripts for managing authentication settings and troubleshooting MFA-related issues.

**Usage:**
```powershell
.\No-MFA.ps1
.\No-MSAuth.ps1
```

### Profile Management Scripts

#### 16. transferUsers.ps1
Transfers FSLogix user profiles from one Azure Fileshare to another. This script is useful for migrating user profiles during storage location changes or data center migrations.

**Features:**
- Supports multiple source and destination Azure Fileshares
- Uses Azure Storage SAS tokens for secure access
- Preserves file permissions and SMB info during transfer
- Includes dry-run capability for testing
- Handles user identification through Microsoft Graph API

**Prerequisites:**
- Microsoft Graph PowerShell SDK
- AzCopy tool installed
- List of users in a text file (C:\temp\users.txt)
- Valid SAS tokens for source and destination Azure Fileshares

**Usage:**
```powershell
.\transferUsers.ps1
```
The script will prompt for SAS tokens for each fileshare and then process the users from the input file.

**Note:** The script runs in dry-run mode by default. Remove the `--dry-run` parameter from the azcopy commands to perform the actual transfer.

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Administrative privileges for most scripts
- Network connectivity for printer and Microsoft 365 related scripts

## Common Issues Resolved

These scripts help resolve several common issues in AVD environments:
- Teams audio/video problems
- Microsoft 365 update management
- Desktop environment configuration
- Service management
- Printer connectivity
- Authentication and MFA issues

## Notes

- Most scripts require administrative privileges
- Some scripts create Windows Event Log entries for auditing
- Scripts are designed for use in Azure Virtual Desktop environments but may work in other Windows environments
- Always test scripts in a non-production environment first

## Author

David Cox