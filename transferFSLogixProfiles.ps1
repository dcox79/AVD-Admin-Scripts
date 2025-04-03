# This script transfers users fslogix profiles from one Azure Fileshare to another.
#Author: David Cox
#Date: 11/11/2024

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Read the usernames from the file
$users = Get-Content -Path "C:\temp\users.txt"

# Prompt for SAS tokens
$sbtprofiles1SASToken = Read-Host -Prompt "Enter the SAS Token for sbtprofiles1"
$sbtprofiles2SASToken = Read-Host -Prompt "Enter the SAS Token for sbtprofiles2"
$ncususerprofSASToken = Read-Host -Prompt "Enter the SAS Token for ncususerprof"
$cususerprofSASToken = Read-Host -Prompt "Enter the SAS Token for cususerprof"

# For each user
foreach ($user in $users)
{
    # Construct the userPrincipalName
    $userPrincipalName = "$user@sterlingbank.com"

    # Get user info from Microsoft Graph
    try
    {
        $userObject = Get-MgUser -UserId $userPrincipalName -Property "id,onPremisesSamAccountName,userPrincipalName"
    }
    catch
    {
        Write-Host "User not found: $userPrincipalName"
        continue
    }

    # Extract username
    $username = $userObject.OnPremisesSamAccountName
    if (-not $username)
    {
        $username = $userObject.MailNickname
    }
    if (-not $username)
    {
        $username = $userObject.UserPrincipalName.Split('@')[0]
    }
    if (-not $username)
    {
        Write-Host "Username not found for user $userPrincipalName"
        continue
    }

    # Build the source and destination URLs without wildcard in the path
    $source1 = "https://sbtprofiles1.file.core.windows.net/user-prof1-centus-prod?$($sbtprofiles1SASToken)"
    $destination1 = "https://ncususerprof.file.core.windows.net/north-central-us-fslogix-fileshare?$($ncususerprofSASToken)"

    $source2 = "https://sbtprofiles2.file.core.windows.net/user-prof1-centus-prod?$($sbtprofiles2SASToken)"
    $destination2 = "https://cususerprof.file.core.windows.net/central-us-fslogix-fileshare?$($cususerprofSASToken)"

    # Define the regex pattern to include directories starting with the username
    $regexPattern = "^$username.*"

    # Output the commands for debugging
    Write-Host "Copying from $source1 to $destination1 with regex '$regexPattern'"
    Write-Host "Copying from $source2 to $destination2 with regex '$regexPattern'"

    # Run the azcopy commands using --include-regex
    azcopy copy "$source1" "$destination1" --recursive --preserve-permissions=true --preserve-smb-info=true --include-regex "$regexPattern" --dry-run

    azcopy copy "$source2" "$destination2" --recursive --preserve-permissions=true --preserve-smb-info=true --include-regex "$regexPattern" --dry-run
}