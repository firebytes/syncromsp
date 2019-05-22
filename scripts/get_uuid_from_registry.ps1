# Version 1.0

# Create Asset Custom Field (TEXT) Called "UUID"
# Change SYNCROSUBDOMAIN

Import-Module $env:SyncroModule
$UUID = (Get-ItemProperty -path 'HKLM:\SOFTWARE\Wow6432Node\RepairTech\Syncro').UUID
write-host $UUID
Set-Asset-Field -Subdomain "SYNCROSUBDOMAIN" -Name "UUID" -Value $UUID

###################################################################################################################################
#  1) After reinstalling Windows, and BEFORE installing SyncroMSP Agent,
#     manually run the following lines with an administrative PS Prompt (Pasting the original UUID in the Value).
#
#     New-Item -path 'HKLM:\SOFTWARE\Wow6432Node\RepairTech\Syncro'
#     New-ItemProperty -path 'HKLM:\SOFTWARE\Wow6432Node\RepairTech\Syncro' -Name UUID -Value "PASTE-UUID" -Type String -Force
#     Get-Service Syncro,SyncroLive | Restart-Service
#
#  3) Install SyncroMSP Agent as normal
###################################################################################################################################
