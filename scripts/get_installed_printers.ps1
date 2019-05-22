# Version 1.0
# Create a custom asset field: "Printers" - text area
# Run as System
# Max run time: 10 minutes


Import-Module $env:SyncroModule

New-Item -ItemType Directory -Force -Path C:\firebytes

Get-Printer |  Select Name,DriverName,Type > C:\firebytes\printers.txt

[string] $text = Get-Content C:\firebytes\printers.txt -Raw

Set-Asset-Field -Subdomain 'firebytes' -Name "Printers" -Value $text

write-host "Set the custom field value to $text"
