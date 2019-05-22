# Version 1.0

# CREATE CUSTOMER CUSTOM FIELD CALLED "MSPAdmin Password"
# Set he following variable as platform variable:
# $MSPAdmin_Password = {{customer_custom_field_mspadmin_password}}

# CHECK TO SEE IF MSPADMIN ACCOUNT EXISTS
$account_exists = (get-localuser -Name "MSPAdmin").count
$MSPAdmin_Password = ConvertTo-SecureString $MSPAdmin_Password -AsPlainText -Force

# IF ACCOUNT EXISTS
if ($account_exists)
    {
    # SET PASSWORD AND NEVER EXPIRES
    Get-LocalUser -Name "MSPAdmin" | Set-Localuser -Password $MSPAdmin_Password -PasswordNeverExpires $False
    Write-Host "Updated MSPAdmin password and set to never expires."
    }
else
    {
    # CREATE LOCAL ACCOUNT
    New-LocalUser -Name 'MSPAdmin' -Description 'MSPAdmin account for Firebytes.' -Password $MSPAdmin_Password
    Write-Host "Created MSPAdmin Account"
    }

# SET TO LOCAL ADMIN
Add-LocalGroupMember -Group 'Administrators' -Member 'MSPAdmin'
Write-Host "Added to Administrators group."

# SET SPECIAL ACCOUNT
$path = 'HKLM:Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
$path_test = Test-Path $path
$key_test = Get-ItemProperty -name "MSPAdmin" -path $path
$value = 0

# CREATE PATH IF NECESSARY
if (!$path_test){
    New-Item -Path $path -Force
    Write-Host "Created registry path."
}
else
{
    Write-Host "Registry Path Exists."
}

# WRITE KEY IF NOT EXISTS
if (!$key_test) {
    New-ItemProperty -Path $path -Name "MSPAdmin" -Value $value
    Write-Host "Added to registry"
    }
else
{
    Write-Host "Key Exists"
}

Write-Host "Script Complete."
