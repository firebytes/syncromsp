# Version 1.0
# Need the following runtime variables:
# $uri (URL to file download)
# $out (file name of downloaded file when saved)
# Run as System
# Max run time: 10 minutes

New-Item -ItemType Directory -Force -Path C:\firebytes

Function Download_MSI{
Invoke-WebRequest -uri $uri -OutFile $out
$msifile = Get-ChildItem -Path $out -File
write-host "Downloaded $msifile "
}
Download_MSI
