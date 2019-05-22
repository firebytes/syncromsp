#TODO - MAKE SURE YOU SETUP YOUR ASSET CUSTOM FIELD CALLED "Product Keys" as a "Text Area" on your
#  Syncro Device asset type. Assets -> Manage Types -> Syncro Device -> New Field

Import-Module $env:SyncroModule

Start-Process -FilePath "C:\temp\produkey.exe" -ArgumentList "/stext C:\temp\keys.txt"

Start-Sleep -Seconds 3

[string] $text = Get-Content C:\temp\keys.txt -Raw

Set-Asset-Field -Subdomain 'firebytes' -Name "Product Keys" -Value $text
write-host "Set the custom field value to $text"
