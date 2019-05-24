Import-Module $env:SyncroModule

$subdomain = "firebytes"
$TicketValue = Create-Syncro-Ticket -Subdomain $subdomain -Subject "Windows 10 Upgrade" -IssueType "Other" -Status "New"
$FileURL="https://s3.wasabisys.com/firebytes-public/Windows1903.iso"
$FileOutput="C:\firebytes\Windows1903.iso"

$StartTime = Get-Date


if (-not (Test-Path $FileOutput)) {
  # TICKET UPDATE - STARTING DOWNLOAD
  Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "File" -Body "File Doesn't Exist - Starting Download" -Hidden $True -DoNotEmail $True

  #Download File
  (New-Object System.Net.WebClient).downloadFile($FileURL,$FileOutput)

  # TICKET UPDATE - File Downloaded
  Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "File" -Body "Finished Download in $((Get-Date).Subtract($StartTime).Seconds) seconds." -Hidden $True -DoNotEmail $True

  Write-host "File downloaded"
}
else {
  write-host "File already exists"
  Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "File" -Body "File already exists - do not download" -Hidden $True -DoNotEmail $True
}



# TEST IF OUTPUT FILE EXISTS
if (Test-Path $FileOutput) {
  # IF THE PATH EXISTS
  write-host "file exists"
  Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "File" -Body "File already exists - go ahead" -Hidden $True -DoNotEmail $True
  write-host "mounting image"
  Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Image" -Body "Mounting Image" -Hidden $True -DoNotEmail $True
  # MOUNTING FILE TO VIRTUAL DRIVE
  $Volume = Mount-DiskImage -ImagePath $FileOutput -passthru | Get-DiskImage | Get-Volume
  write-host $Volume.DriveLetter

  # START WINDOWS UPGRADE CHECK
  write-host "start check"
  Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Install" -Body "Starting Check" -Hidden $True -DoNotEmail $True
  $SetupPath = "$($Volume.DriveLetter):\setup.exe"

  # IF SETUP PATH EXISTS - START UPGRADE CHECK
  if (Test-Path $SetupPath) {

    write-host $SetupPath

    $SetupProcess = Start-Process `
           -FilePath $SetupPath `
           -ArgumentList "/auto Upgrade /quiet /Compat ScanOnly /DynamicUpdate enable" `
           -RedirectStandardError c:\firebytes\win_error.log `
           -RedirectStandardOutput c:\firebytes\win_output.log `
           -Passthru `
           -Wait

    Write-Host $SetupProcess.ExitCode

    # IF ERROR CODE
    if ($SetupProcess.ExitCode -ne -1047526896) {
      switch ($SetupProcess.ExitCode) {
        -1047526904 {
          Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body "0xC1900208 - Compatibility Issue" -Hidden $True -DoNotEmail $True
        }
        -1047526908 {
          Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body "0xC1900204 - Migration Choice not available" -Hidden $True -DoNotEmail $True
        }
        -1047526912 {
          Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body "0xC1900200 - Not eligible for Windows 10" -Hidden $True -DoNotEmail $True
        }
        -1047526898 {
          Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body "0xC190020E - Not enough free space" -Hidden $True -DoNotEmail $True
        }
        default {
          Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body $SetupProcess.ExitCode -Hidden $True -DoNotEmail $True
        }
      }
      write-host "error Code: $($SetupProcess.ExitCode)"
      '{0:X}' -f $SetupProcess.ExitCode
      dismount-diskimage -ImagePath $FileOutput
      Exit 1
    }
    # IF NO ERROR CODE
    else {
      write-host "RUN SETUP NOW"
      Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Install" -Body "Create Scheduled Task" -Hidden $True -DoNotEmail $True

      $now=Get-Date
      $OneMinute=$now.AddSeconds(60)
      $Trigger = New-ScheduledTaskTrigger -Once -At $OneMinute
      $Settings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -DeleteExpiredTaskAfter "2 Days"
      $User = "NT AUTHORITY\SYSTEM"
      $Argument = "/auto Upgrade /quiet /Compat ScanOnly /DynamicUpdate enable"
      $Action = New-ScheduledTaskAction -Execute $SetupPath -Argument $Argument

      # IF SCHEDULED TASK IS CREATED
      if (Register-ScheduledTask -TaskName "Upgrade Windows 10" -Trigger $Trigger -User $User -Action $Action -Settings $Settings -RunLevel Highest -Force) {
        Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Install" -Body "Scheduled Task Created" -Hidden $True -DoNotEmail $True
      }
      # IF SCHEDULED TASK IS NOT CREATED
      else {
        Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body "Scheduled Task Not Created $($error[0])" -Hidden $True -DoNotEmail $True
        Exit 1
      }
    } # END OF NO ERROR CODE
  }
  # IF SETUP PATH DOES NOT EXIST
  else {
    Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body "Setup path of $($SetupPath) does not exist." -Hidden $True -DoNotEmail $True
    Exit 1
  }
}
else {
  write-host "file not downloaded correctly"
  Create-Syncro-Ticket-Comment -Subdomain $subdomain -TicketIdOrNumber $TicketValue.ticket.id -Subject "Failed" -Body "File not downloaded correctly" -Hidden $True -DoNotEmail $True
  Exit 1
}
