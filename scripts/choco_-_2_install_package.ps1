# Version 1.0
# Add package name from chocolatey to $package variable
# Run as System
# Max run time: 30 minutes

Import-Module $env:SyncroModule

$path = "$($env:ProgramData)\chocolatey\bin\choco.exe"
write-host $path
$package = "adobereader"
& $path install $package -y
