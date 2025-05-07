#example: $ServicesToDisable = ("RasAuto","RpcLocator","upnphost","wsa_proxy")
$ServicesToDisable = ("wsa_proxy")
foreach ($Service in $ServicesToDisable) {
    try {
        $serviceStatus = Get-Service $Service -ErrorAction Stop
        if ($serviceStatus.StartType -ne "Disabled") {
            exit 1
        }
    }
    catch {
        # Service doesn't exist, treat it the same as disabled
        continue
    }
}
exit 0