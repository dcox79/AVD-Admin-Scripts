# Teams Cache Clearing Script

This PowerShell script helps resolve common Microsoft Teams issues by clearing the Teams cache and restarting the application. It's particularly useful for Azure Virtual Desktop (AVD) environments where Teams cache issues can impact performance and functionality.

## Features

- Safely closes all Teams processes
- Clears Teams cache files
- Provides user notifications about the process
- Automatically restarts Teams after cleanup
- Handles both Microsoft Store and classic desktop versions of Teams
- Non-interactive execution (no user prompts)

## Usage

1. Download the `clearTeamsCache.ps1` script
2. Run the script directly in PowerShell:
   ```powershell
   .\clearTeamsCache.ps1
   ```

## What the Script Does

1. Shows a notification to save any ongoing work in Teams
2. Closes all running Teams processes
3. Clears the Teams cache from the user's profile
4. Restarts Teams automatically
5. Notifies the user when the process is complete

## Notes

- The script runs in user context (no admin privileges required)
- Some files may be locked by the system and cannot be deleted - this is normal and won't affect the cache clearing process
- The script includes a 7-second delay after the initial notification to allow users to save their work

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Microsoft Teams installed (Store or desktop version)

## Author

David Cox 