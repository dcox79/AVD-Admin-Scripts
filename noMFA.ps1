# Author: Dave Cox
# Date: 11/11/2024
# This script checks for MFA registration in a specified group.
# Designed for Intune remediation.

# Define the group name - this should be updated with your organization's group name
$groupName = "Baseline - Microsoft 365 Users"

function Connect-ToMicrosoftGraph {
    $requiredScopes = @("User.Read.All", "Group.Read.All", "UserAuthenticationMethod.Read.All")
    $connection = Connect-MgGraph -Scopes $requiredScopes -ErrorAction SilentlyContinue
    if (-not $connection) {
        Write-Error "Failed to connect to Microsoft Graph. Please ensure you have consent for the required permissions."
        exit 1  # Non-Compliant
    }
    Write-Output "Connected to Microsoft Graph."
}

function Get-GroupMembersRecursively {
    param (
        [string]$GroupId
    )
    
    $groupMembers = Get-MgGroupMember -GroupId $GroupId -All
    $nonCompliantUsers = @()
    
    foreach ($member in $groupMembers) {
        $memberType = $member.AdditionalProperties["@odata.type"]
        
        if ($memberType -eq "#microsoft.graph.user") {
            $user = Get-MgUser -UserId $member.Id
            $displayName = $user.DisplayName
            $authMethods = Get-MgUserAuthenticationMethod -UserId $member.Id
            
            if ($authMethods.Count -lt 2) {
                $nonCompliantUsers += $displayName
                Write-Output "$displayName Does not have MFA Registered"
            }
        } elseif ($memberType -eq "#microsoft.graph.group") {
            Get-GroupMembersRecursively -GroupId $member.Id
        }
    }
    
    return $nonCompliantUsers
}

# Main script logic
try {
    # Check if Microsoft Graph PowerShell SDK is installed
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
        Write-Output "Microsoft Graph PowerShell SDK not found. Installing..."
        Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
        Import-Module Microsoft.Graph
    } else {
        Write-Output "Microsoft Graph PowerShell SDK is installed."
    }

    # Connect to Microsoft Graph
    Connect-ToMicrosoftGraph

    # Process the specified group
    $group = Get-MgGroup -Filter "displayName eq '$groupName'"
    if ($group) {
        Write-Output "Starting to process group: $($group.DisplayName)"
        $nonCompliantUsers = Get-GroupMembersRecursively -GroupId $group.Id
        
        if ($nonCompliantUsers.Count -gt 0) {
            Write-Output "Found $($nonCompliantUsers.Count) users without MFA"
            exit 1  # Non-Compliant
        } else {
            Write-Output "All users in group have MFA registered"
            exit 0  # Compliant
        }
    } else {
        Write-Error "Group not found: $groupName"
        exit 1  # Non-Compliant
    }
} catch {
    Write-Error "Unexpected error: $_"
    exit 1  # Non-Compliant
}
