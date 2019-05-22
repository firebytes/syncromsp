# Version 1.0
# Use the following runtime variables:
# $out = name of outputted file
# $uri = URL of MSI File
# Run as System\

Function Download_MSI{
Invoke-WebRequest -uri $uri -OutFile $out
$msifile = Get-ChildItem -Path $out -File -Filter '*.ms*'
write-host "DOwnloaded MSI $msifile "
}

Function Install{
$FileExists = Test-Path $out -IsValid
$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}.log' -f $DataStamp
$MSIArguments = @("/i $out","/qn","/norestart","/L*v $logFile")
If ($FileExists -eq $True)
{
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -passthru | wait-process
write-host "Finished msi "$msifile
}

Else {Write-Host "File doesn't exist"}
}
Download_MSI
Install
