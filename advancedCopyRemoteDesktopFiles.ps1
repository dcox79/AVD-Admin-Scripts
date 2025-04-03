# Prompt for domain credentials
$credential = Get-Credential -Message "Enter domain credentials"

# Prompt for the username
$username = Read-Host "Enter the username"

# Prompt for the remote computer name
$remoteComputerName = Read-Host "Enter the remote computer name"

# Define source folders and target folder
$sourceFolders = @("Desktop", "Documents", "Pictures", "Downloads", "Videos")
$targetBaseFolder = "\\sterling1.sbt.local\d$\USER\$username\Remote Desktop Files"

# Define file extensions to copy
$mediaExtensions = @("*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.mp3", "*.mp4", "*.avi", "*.mkv", "*.mov", "*.txt", "*.doc", "*.docx", "*.xls", "*.xlsx", "*.ppt", "*.pptx", "*.pdf")

# Convert the credentials to a PSCredential object for use with the NET USE command
$netCredential = New-Object System.Management.Automation.PSCredential($credential.UserName, $credential.Password)

# Map the remote user's folder using the given credentials
$remoteUserFolder = "\\$remoteComputerName\c$\users\$username"
net use $remoteUserFolder ($netCredential.GetNetworkCredential().Password) /user:$($netCredential.UserName) /persistent:no

# Copy media and document files from source folders to the target folder
foreach ($folder in $sourceFolders) {
    $sourceFolder = "$remoteUserFolder\$folder"
    $destinationFolder = "$targetBaseFolder\$folder"

    if (!(Test-Path $destinationFolder)) {
        New-Item -ItemType Directory -Path $destinationFolder
    }

    foreach ($ext in $mediaExtensions) {
        Get-ChildItem -Path $sourceFolder -Filter $ext -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Copy-Item -Path $_.FullName -Destination $destinationFolder -ErrorAction Stop
            } catch {
                Write-Warning "Failed to copy $($_.FullName): $($_.Exception.Message)"
            }
        }
    }
}

# Disconnect the network drive
net use $remoteUserFolder /delete

Write-Host "Media and document files copied successfully"
