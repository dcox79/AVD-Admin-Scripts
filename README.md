# Teams Cache Clearing Scripts for Azure Virtual Desktop

This repository contains PowerShell scripts to help resolve common Microsoft Teams issues in Azure Virtual Desktop (AVD) environments, particularly focusing on microphone and camera access problems that can be resolved by clearing the Teams cache.

## Scripts

### 1. clearTeamsCache.ps1

A script that runs locally on a user's session to clear the Teams cache.

**Features:**
- Safely closes all Teams processes
- Clears Teams cache files
- Provides user notifications about the process
- Automatically restarts Teams after cleanup
- Handles both Microsoft Store and classic desktop versions of Teams
- Non-interactive execution (no user prompts)

**Usage:**
```powershell
.\clearTeamsCache.ps1
```

### 2. RemoteTeamsCacheCleaner.ps1

A script designed to be run by administrators to remotely clear a specific user's Teams cache on AVD session hosts.

**Features:**
- Can be run remotely against any session host
- Targets a specific user's Teams cache
- Safely stops Teams processes for the target user
- Clears the Teams cache
- Restarts Teams for the user using a scheduled task
- No user interaction required

**Usage:**
```powershell
# Example 1: Clear Teams cache for a user on the local session host
.\RemoteTeamsCacheCleaner.ps1 -UserName "contoso\jsmith"

# Example 2: Clear Teams cache for a user on a specific session host
.\RemoteTeamsCacheCleaner.ps1 -UserName "contoso\jsmith" -SessionHostName "avd-host-pool-0"
```

## Common Issues Resolved

These scripts help resolve several common Teams issues in AVD environments:
- Loss of microphone access
- Camera not working
- Audio device selection problems
- Teams freezing or crashing
- Call quality issues

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Microsoft Teams installed (Store version preferred for AVD)
- For remote execution: Administrative access to session hosts

## Notes

- The remote script requires administrative privileges on the target session host
- For the remote script, the target user must have an active profile on the session host
- Some files may be locked by the system and cannot be deleted - this is normal and won't affect the cache clearing process

## Author

David Cox 