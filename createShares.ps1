$command = {
## Variables
$path = "c:\Patches"
$share = "Patches"
## Create Folder
IF (!(test-path $path)){
write-host "Creating folder: " $path -ForegroundColor green
New-Item -Path $path -ItemType directory
} else {
write-host "The folder already exists: "$path -ForegroundColor Yellow
}
 
## Create Share
IF (!(Get-SmbShare -Name $share -ErrorAction SilentlyContinue)) {
write-host "Creating share: " $share -ForegroundColor green
New-SmbShare –Name $share –Path $path –Description ‘PatchMan Share’ –FullAccess "sbt\Patchman"
} else {
write-host "The share already exists: " $share -ForegroundColor Yellow
}
}
$servers = get-content "C:\Temp\servers.txt"
Invoke-Command -ComputerName $servers -scriptblock $command