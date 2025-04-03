# Attempt to set the execution policy to Unrestricted
param(
    [Parameter(Mandatory=$true)]
    [string]$GroupName
)

try {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Write-Host "Execution policy set to Unrestricted."
} catch {
    Write-Error "Failed to set execution policy to Unrestricted. Please run PowerShell as Administrator or check execution policy restrictions."
    exit
}

# Check if Microsoft Graph PowerShell SDK is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Microsoft Graph PowerShell SDK not found. Installing..."
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
    Import-Module Microsoft.Graph
} else {
    Write-Host "Microsoft Graph PowerShell SDK is installed."
}

# Function to connect to Microsoft Graph with required scopes
function Connect-ToMicrosoftGraph {
    $requiredScopes = @("User.Read.All", "Group.Read.All", "UserAuthenticationMethod.Read.All")
    $connection = Connect-MgGraph -Scopes $requiredScopes -ErrorAction SilentlyContinue
    if (-not $connection) {
        Write-Error "Failed to connect to Microsoft Graph. Please ensure you have consent for the required permissions."
        exit
    }
    Write-Host "Connected to Microsoft Graph."
}

# Main function to process group members
function Get-GroupMembersRecursively {
    param (
        [string]$GroupId
    )
    
    $groupMembers = Get-MgGroupMember -GroupId $GroupId -All
    
    foreach ($member in $groupMembers) {
        $memberType = $member.AdditionalProperties["@odata.type"]
        
        if ($memberType -eq "#microsoft.graph.user") {
            $user = Get-MgUser -UserId $member.Id
            $displayName = $user.DisplayName
            $authMethods = Get-MgUserAuthenticationMethod -UserId $member.Id
            $hasAuthenticator = $false
            
            foreach ($method in $authMethods) {
                $methodType = $method.AdditionalProperties["@odata.type"]
                if ($methodType -eq "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod") {
                    $hasAuthenticator = $true
                    break
                }
            }
            
            if (-not $hasAuthenticator) {
                Write-Output "$displayName Does not have Microsoft Authenticator"
            }
        } elseif ($memberType -eq "#microsoft.graph.group") {
            Get-GroupMembersRecursively -GroupId $member.Id
        }
    }
}

# Connect to Microsoft Graph
Connect-ToMicrosoftGraph

# Process the specified group
$group = Get-MgGroup -Filter "displayName eq '$GroupName'"
if ($group) {
    Write-Host "Starting to process group: $($group.DisplayName)"
    Get-GroupMembersRecursively -GroupId $group.Id
} else {
    Write-Host "Group not found."
}
