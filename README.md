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

### Microsoft 365 Management Scripts

#### 5. Detect-Microsoft365AppsUpdate.ps1
Detects if Microsoft 365 Apps need updates by comparing installed versions against minimum required versions for different update channels.

**Usage:**
```powershell
.\Detect-Microsoft365AppsUpdate.ps1
```

#### 6. Remediate-Microsoft365AppsUpdate.ps1
Remediates Microsoft 365 Apps that need updates by triggering the update process.

**Usage:**
```powershell
.\Remediate-Microsoft365AppsUpdate.ps1
```

### Desktop Environment Scripts

#### 7. AddOfficeIcons.ps1
Creates desktop shortcuts for Microsoft Office applications.

**Features:**
- Creates shortcuts for Word, Excel, PowerPoint, Outlook, OneNote, and Visio
- Handles both 32-bit and 64-bit Office installations
- Verifies successful creation of each shortcut

**Usage:**
```powershell
.\AddOfficeIcons.ps1
```

#### 8. detect-numlock.ps1 and set-numlock.ps1
Scripts to detect and set NumLock state at startup.

**Usage:**
```powershell
# To check NumLock status
.\detect-numlock.ps1

# To enable NumLock at startup
.\set-numlock.ps1
```

### Printer Management Scripts

#### 9. AddHRCheck.ps1
Adds the HRCheck network printer to the machine.

**Usage:**
```powershell
.\AddHRCheck.ps1
```

### Authentication Scripts

#### 10. No-MFA.ps1 and No-MSAuth.ps1
Scripts for managing authentication settings and troubleshooting MFA-related issues.

**Usage:**
```powershell
.\No-MFA.ps1
.\No-MSAuth.ps1
```

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