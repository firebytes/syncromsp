# Version 1.0
# Run as System
# Max run time: 10 minutes

Import-Module $env:SyncroModule

$path = "$($env:ProgramData)\chocolatey\bin\choco.exe"
if (Test-Path $path) {
    Write-host "Choco already exists"
    write-host $path
} else {
    Write-host "Choco does not exist. Installing Choco..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Write-host "Enabling global confirmation"
    & $path feature enable -n=allowGlobalConfirmation
    Write-host "Completed"
}
