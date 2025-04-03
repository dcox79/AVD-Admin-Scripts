# Define the source and destination paths
$desktopPath = "$env:userprofile\Desktop"
$myDocumentsPath = "$env:userprofile\Documents"
$destinationPath = "F:\Remote Desktop Files"

# Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath | Out-Null
}

# Copy text, word, excel, and PDF files from the Desktop and My Documents folders to the destination folder
Get-ChildItem -Path $desktopPath, $myDocumentsPath -Include *.txt,*.doc,*.docx,*.xls,*.xlsx,*.pdf -Recurse |
    Copy-Item -Destination $destinationPath