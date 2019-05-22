# Version 1.0
# Run as System
# Max run time: 10 minutes

$path = 'HKLM:Software\Policies\Google\Chrome\ExtensionInstallForcelist'
$path_test = Test-Path $path
$key_test = Get-ItemProperty -name "1" -path $path
$value = "agoebdicoenidlkgnfhcjblfkjmplnha;https://clients2.google.com/service/update2/crx"

if (!$path_test){
    New-Item -Path $path -Force
}
else {
    Write-Host "Path Exists"
}

if ($key_test){
    write-host "Key Exists"
}
else
{
    New-ItemProperty -Path $path -Name "1" -Value $value
    write-host "Updated registry"
}
