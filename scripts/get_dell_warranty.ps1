# Version 1.0
# Run as System
# Max run time: 10 minutes

#script credit to https://github.com/connochio
#Couple things that need improvement
#Probably need to put a random time function to spread these lookups over a few minutes if running on a lot of systems at the same time
#Put in a check before execution that the machine is actually a dell and stop if not a dell
#Appears some warranties won't be read cleanly in the warrantytype. Need some more tlc there and to break out initial and extended warranty sections.
Import-Module $env:SyncroModule
$APIKey = "CHANGE_ME"
$subdomain = "CHANGE_ME"
$ServiceTag = $(Get-WmiObject -Class "Win32_Bios").SerialNumber
$URI = "https://api.dell.com/support/assetinfo/v4/getassetwarranty/${ServiceTag}?apikey=${APIKey}"
$Request = Invoke-RestMethod -URI $URI -Method GET
$Warranties = $Request.AssetWarrantyResponse.assetentitlementdata | where {$_.ServiceLevelDescription -NE 'Dell Digitial Delivery' -and $_.ServiceLevelDescription -NE 'Collect and Return Support'}
$AssetDetails = $Request.AssetWarrantyResponse.assetheaderdata

$EndDate = $Request.AssetWarrantyResponse.assetentitlementdata | where {$_.ServiceLevelDescription -NE 'Dell Digitial Delivery' -and $_.ServiceLevelDescription -NE 'Collect and Return Support'} | select -expand EndDate
$EndDateD = $EndDate.split("T") | select -First 1
$StartDate = $Request.AssetWarrantyResponse.assetentitlementdata | where {$_.ServiceLevelDescription -NE 'Dell Digitial Delivery' -and $_.ServiceLevelDescription -NE 'Collect and Return Support'} | select -expand StartDate
$StartDateC = $StartDate.split("T") | select -Last 2
$StartDated = $StartDateC.split("T") | select -First 1
$Support = $Request.AssetWarrantyResponse.assetentitlementdata | where {$_.ServiceLevelDescription -NE 'Dell Digitial Delivery' -and $_.ServiceLevelDescription -NE 'Collect and Return Support'} | select -expand ServiceLevelDescription
$Device = $Request.AssetWarrantyResponse.ProductHeaderData | select -expand SystemDescription
$Shipped = $Request.AssetWarrantyResponse.AssetHeaderData | select -expand ShipDate
$ShippedD = $Shipped.split("T") | select -SkipLast 1

Set-Asset-Field -Subdomain $subdomain -Name "WarrantyStartDate" -Value $StartDateD
Set-Asset-Field -Subdomain $subdomain -Name "WarrantyEndDate" -Value $EndDateD
Set-Asset-Field -Subdomain $subdomain -Name "WarrantyType" -Value $Support

Write-Host "This machine's warranty started: $StartDateD"
Write-host "This machine's warranty ends:    $EndDateD"
Write-Host "The support Level is:            $Support"
