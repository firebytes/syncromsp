# Version 1.0
# SophosSetup.exe uploaded to Syncro - Destination: c:\firebytes\SophosSetup.exe
# Create the following custom customer fields:
# sophos_management_server (text field)
# sophos_customer_token (text field)
# Map the following platform variables:
# $sophos_server = {{customer_custom_field_sophos_management_server}}
# $sophos_token = {{customer_custom_field_sophos_customer_token}}
# Run as System
# Max run time: 29 minutes

$path = "c:\firebytes\SophosSetup.exe"
$args = @("--customertoken=$sophos_token","--mgmtserver=$sophos_server","--products=antivirus,intercept","--quiet")

function Check_Program_Installed( $programName ) {
$wmi_check = (Get-WMIObject -Query "SELECT * FROM Win32_Product Where Name Like '%$programName%'").Length -gt 0
return $wmi_check;
}

if (Check_Program_Installed("Sophos Endpoint")){
    Write-Host "Program Already Installed"
}
else
{
    Write-Host "Program Not Installed. Installing program."
    Start-Process -FilePath $path -ArgumentList $args -passthru | wait-process
    Write-Host "Finished installing."
}
