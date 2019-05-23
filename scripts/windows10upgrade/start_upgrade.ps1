Import-Module $env:SyncroModule

$FileURL="https://f001.backblazeb2.com/file/Firebytes-Public/dban-2.3.0_i586.iso"
$FileOutput="C:\firebytes\Windows1809.iso"

function downloadFile($url, $targetFile)
{
    "Downloading $url"
    $uri = New-Object "System.Uri" "$url"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes = $count
    while ($count -gt 0)
    {
        [System.Console]::CursorLeft = 0
        [System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes = $downloadedBytes + $count
    }
    "Finished Download"
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
}

if (-not (Test-Path $FileOutput)) {
  downloadFile $FileURL $FileOutput
  Write-host "File downloaded"
} else {
  write-host "File already exists"
}



if (Test-Path $FileOutput) {
  # EXTRACT SOMEHOW
  write-host "file exists"
  write-host "mounting image"
  $Volume = Mount-DiskImage -ImagePath $FileOutput -passthru | Get-DiskImage | Get-Volume
  write-host $Volume.DriveLetter

    #Create batchfile for upgrade on each computer
  write-host "start check"
  $SetupPath = "$($Volume.DriveLetter):\setup.exe"
  write-host $SetupPath

  $SetupProcess = Start-Process `
         -FilePath $SetupPath `
         -ArgumentList "/auto Upgrade /quiet /Compat ScanOnly /DynamicUpdate disable" `
         -RedirectStandardError c:\firebytes\win_error.log `
         -RedirectStandardOutput c:\firebytes\win_output.log `
         -Passthru `
         -Wait

  Write-Host $SetupProcess.ExitCode
  if ($SetupProcess.ExitCode -ne -1047526896) {

    write-host "error Code: $($SetupProcess.ExitCode)"
    '{0:X}' -f $SetupProcess.ExitCode
    dismount-diskimage -ImagePath $FileOutput
    Exit 2
  } else {
    write-host "RUN SETUP NOW"

    $InstallProcess = Start-Process `
           -FilePath $SetupPath `
           -ArgumentList "/auto Upgrade /quiet /Compat IgnoreWarning /DynamicUpdate disable" `
           -RedirectStandardError c:\firebytes\win_error.log `
           -RedirectStandardOutput c:\firebytes\win_output.log
  }

#CHECK RESULT???


###########################################
} else {
  write-host "file not downloaded correctly"
}
