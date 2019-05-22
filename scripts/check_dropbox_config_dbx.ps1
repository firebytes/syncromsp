# Version 1.0
# Need to add platform variable:
# $asset_name = {{asset_name}}
# Max Run Time: 3 minutes
# Execute as: System

Import-Module $env:SyncroModule

$subdomain = "REPLACE_ME"
$email_address = "REPLACE_ME"

$source = "C:\Users\Dropbox\AppData\Local\Dropbox\instance1\config.dbx"
$file_date = [datetime](Get-ItemProperty -Path $source -Name LastWriteTime).LastWriteTime
$now_minus = (Get-Date).AddMinutes(-120)
$now = Get-Date
if ($file_date -gt $now_minus){
$output=1
}
if ($output -ne 1){
    Send-Email -Subdomain $subdomain -To $email_address -Subject "Dropbox Failed - $asset_name" -Body "Dropbox config.dbx has not been updated since $file_date on $asset_name. `r`n Sent: $now"
}
