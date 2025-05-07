# Author: David Cox
# Date: 11/11/2024
# This script adds Office icons to the desktop.

$desktopPath = [Environment]::GetFolderPath("Desktop")

function CreateShortcut($appName, $exeName) {
    $shortcutPath = Join-Path -Path $desktopPath -ChildPath "$appName.lnk"
    $officePaths = @(
        "${env:ProgramFiles}\Microsoft Office\root\Office16",
        "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16",
        "${env:ProgramFiles}\Microsoft Office",
        "${env:ProgramFiles(x86)}\Microsoft Office"
    )

    foreach ($officePath in $officePaths) {
        $exePath = Join-Path -Path $officePath -ChildPath $exeName
        if (Test-Path $exePath) {
            try {
                $WshShell = New-Object -ComObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut($shortcutPath)
                $Shortcut.TargetPath = $exePath
                $Shortcut.IconLocation = $exePath
                $Shortcut.Save()
                Write-Host "$appName shortcut created successfully."
                return $true
            } catch {
                Write-Error "Failed to create $appName shortcut. Error: $_"
                return $false
            }
        }
    }

    Write-Warning "$appName executable not found in specified paths."
    return $false
}

$officeApps = @{
    "Word" = "WINWORD.EXE";
    "Excel" = "EXCEL.EXE";
    "PowerPoint" = "POWERPNT.EXE";
    "Outlook" = "OUTLOOK.EXE";
    "OneNote" = "ONENOTE.EXE";
    "Visio" = "VISIO.EXE";
}

$success = $true

foreach ($appName in $officeApps.Keys) {
    $exeName = $officeApps[$appName]
    $result = CreateShortcut $appName $exeName
    if (-not $result) {
        $success = $false
    }
}

if ($success) {
    Write-Host "All Office shortcuts were added successfully."
    exit 0
} else {
    Write-Host "One or more Office shortcuts failed to be added."
    exit 1
}

