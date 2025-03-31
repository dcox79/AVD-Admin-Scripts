# Define services to stop
#example: $ServicesToStop = ("RasAuto","RpcLocator","upnphost","wsa_proxy")
$ServicesToStop = ("wsa_proxy")
$ScriptName = "Service Stop Script"
$LogName = "Application"

# Create a new event source if it doesn't exist
try {
    if (![System.Diagnostics.EventLog]::SourceExists($ScriptName)) {
        New-EventLog -LogName $LogName -Source $ScriptName
    }
}
catch {
    # If we can't create the event source, we'll fall back to System log with System source
    $ScriptName = "System"
    $LogName = "System"
}

foreach ($Service in $ServicesToStop) {
    try {
        $serviceStatus = Get-Service $Service -ErrorAction Stop
        
        if ($serviceStatus.Status -eq "Running") {
            # Attempt to stop the service
            Stop-Service -Name $Service -Force -ErrorAction Stop
            
            Write-EventLog -LogName $LogName -Source $ScriptName -EventId 1000 -EntryType Information `
                -Message "Successfully stopped service: $Service"
        }
        else {
            Write-EventLog -LogName $LogName -Source $ScriptName -EventId 1001 -EntryType Information `
                -Message "Service $Service is already stopped. No action needed."
        }
    }
    catch {
        if ($_.Exception.Message -like "*Cannot find any service with service name*") {
            Write-EventLog -LogName $LogName -Source $ScriptName -EventId 1002 -EntryType Information `
                -Message "Service $Service does not exist on this system. No action needed."
        }
        else {
            Write-EventLog -LogName $LogName -Source $ScriptName -EventId 1003 -EntryType Error `
                -Message "Error processing service $Service. Error: $($_.Exception.Message)"
        }
    }
} 