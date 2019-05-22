#Create System Restore Point named On-Boarding
#Create folder C:\firebytes


#Version 1.0-

# 1 - Create the restore point
Checkpoint-Computer -Description "Onboarding" -RestorePointType "MODIFY_SETTINGS"
Write-Host "System Restore Point created successfully"

# 2 - Create folder C:\firebytes

$nfldr = new-object -ComObject scripting.filesystemobject
$nfldr.CreateFolder("C:\firebytes")
Write-Host "Folder Created"
