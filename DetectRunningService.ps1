#example: $ServicesToCheck = ("RasAuto","RpcLocator","upnphost","wsa_proxy")
$ServicesToCheck = ("wsa_proxy")

foreach ($Service in $ServicesToCheck) {
    try {
        $serviceStatus = Get-Service $Service -ErrorAction Stop
        if ($serviceStatus.Status -eq "Running") {
            # Exit with 1 if any service is running - needs remediation
            exit 1
        }
    }
    catch {
        # Service doesn't exist, treat it the same as stopped
        continue
    }
}
# Exit with 0 if no services are running - no remediation needed
exit 0