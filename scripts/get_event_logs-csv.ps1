# Version 1.0

#
#  This script exports consolidated and filtered event logs to CSV
#  Author: Michael Karsyan, FSPro Labs, eventlogxp.com (c) 2016
#
Import-Module $env:SyncroModule

$subdomain = "firebytes"

Set-Variable -Name EventAgeDays -Value 3     #we will take events for the latest 7 days
Set-Variable -Name LogNames -Value @("Application", "System")  # Checking app and system logs
Set-Variable -Name EventTypes -Value @("Error", "Warning")  # Loading only Errors and Warnings
Set-Variable -Name ExportFolder -Value "C:\firebytes\"


$el_c = @()   #consolidated error log
$now=get-date
$startdate=$now.adddays(-$EventAgeDays)
$ExportFile=$ExportFolder + "el" + $now.ToString("yyyy-MM-dd---hh-mm-ss") + ".csv"  # we cannot use standard delimiteds like ":"


foreach($log in $LogNames)
{
  Write-Host Processing $comp\$log
  # $el = get-eventlog -ComputerName $comp -log $log -After $startdate -EntryType $EventTypes
  $el = get-eventlog -log $log -After $startdate -EntryType $EventTypes
  $el_c += $el  #consolidating
}
$el_sorted = $el_c | Sort-Object TimeGenerated -Descending   #sort by time
Write-Host Exporting to $ExportFile
$el_sorted|Select EntryType, TimeGenerated, Source, EventID, MachineName, Message | Export-CSV $ExportFile -NoTypeInfo  #EXPORT
Write-Host Done!

# Attach file to Asset
Upload-File -Subdomain $subdomain -FilePath $ExportFile
Write-Host "Exported to Syncro"
Remove-Item -path $ExportFile
Write-Host "Deleted File on Local Machine"
