$src = "\\Sterling1\user"
$dest = "X:\Former Employee F Drives"
do { $naam = Read-Host -Prompt "Please enter user folder name" } 
while(-not $naam)
robocopy (Join-Path $src $naam) (Join-Path $dest $naam) /E /DCOPY:T /COPYALL