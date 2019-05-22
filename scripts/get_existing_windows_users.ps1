# Version 1.0
# Create custom asset variable: "Local Users" - text area
# Run as System
# Max run time: 10 minutes

Import-Module $env:SyncroModule

New-Item -ItemType Directory -Force -Path C:\firebytes

Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" |  Select Name,Disabled > C:\firebytes\sri.txt

[string] $text = Get-Content C:\firebytes\sri.txt -Raw

Set-Asset-Field -Subdomain 'firebytes' -Name "Local Users" -Value $text

write-host "Set the custom field value to $text"
