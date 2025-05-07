# Remediation script to install Company Portal
$applicationId = "9wzdncrfj3pz"

# Create a CIM session
$namespaceName = "root\\cimv2\\mdm\\dmmap"
$session = New-CimSession

# Define the OMA-URI for app installation
$omaUri = "./Vendor/MSFT/EnterpriseModernAppManagement/AppInstallation"

# Create a new CIM instance for app installation
$newInstance = New-Object Microsoft.Management.Infrastructure.CimInstance "MDM_EnterpriseModernAppManagement_AppInstallation01_01", $namespaceName
$property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ParentID", $omaUri, "string", "Key")
$newInstance.CimInstanceProperties.Add($property)
$property = [Microsoft.Management.Infrastructure.CimProperty]::Create("InstanceID", $applicationId, "String", "Key")
$newInstance.CimInstanceProperties.Add($property)

# Define the parameters for the StoreInstallMethod
$flags = 0
$paramValue = [Security.SecurityElement]::Escape("<Application id=`"$applicationId`" flags=`"$flags`"/>")
$params = New-Object Microsoft.Management.Infrastructure.CimMethodParametersCollection
$param = [Microsoft.Management.Infrastructure.CimMethodParameter]::Create("param", $paramValue, "String", "In")
$params.Add($param)

# Invoke the StoreInstallMethod to install the app
try {
    $instance = $session.CreateInstance($namespaceName, $newInstance)
    $result = $session.InvokeMethod($namespaceName, $instance, "StoreInstallMethod", $params)
} catch [Exception] {
    Write-Host $_ | Out-String
}

# Remove the CIM session
Remove-CimSession -CimSession $session
