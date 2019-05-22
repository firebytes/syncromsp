# Version 1.0
# Gets 1000 events from System and Application logs and attaches as text file to asset.
# Run as System

Import-Module $env:SyncroModule

$now=get-date
$NoOfEvents = 1000
$subdomain = "CHANGE_ME"
$ExportFolder = "C:\CHANGE_ME\"
$ApplicationFile = $ExportFolder + $now.ToString("yyyyMMdd-hh-mm-ss") + "app_event_logs.txt"
$SystemFile = $ExportFolder + $now.ToString("yyyyMMdd-hh-mm-ss") + "sys_event_logs.txt"


# Get Application Logs
$result = Get-WinEvent -Logname Application -MaxEvents $NoOfEvents | Where { $_.LevelDisplayName -eq "Error" -or $_.LevelDisplayName -eq "Warning" } | format-table -wrap
write-output $result > $ApplicationFile
Upload-File -Subdomain $subdomain -FilePath $ApplicationFile


#Get System Logs
$result = Get-WinEvent -Logname System -MaxEvents $NoOfEvents | Where { $_.LevelDisplayName -eq "Error" -or $_.LevelDisplayName -eq "Warning" } | format-table -wrap
write-output $result > $SystemFile
Upload-File -Subdomain $subdomain -FilePath $SystemFile

# Cleanup temp txt files
remove-item $ApplicationFile
remove-item $SystemFile
