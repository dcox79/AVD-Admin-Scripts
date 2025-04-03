# Enable Remote Desktop printer redirection
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" -Name "fEnablePrintRDR" -Value 1