################################################  Powershell Support Form for Syncro  ##########################################################
#################################  Made with instsructional assistance from Dan Stolts "ITProGuru"  ############################################
### https://channel9.msdn.com/Series/GuruPowerShell/GUI-Form-Using-PowerShell-Add-Panel-Label-Edit-box-Combo-Box-List-Box-CheckBox-and-More  ###
################################################################################################################################################
<#
- Create new "CMD" menu item under Device System Tray Menu in your Policy
- Give it a title (I used 'New Support Ticket')
- Option 1 - Automated - Insert this into the CMD line, replacing YOUR_DOMAIN_HERE with your own Syncro subdomain:
powershell -ExecutionPolicy Bypass "Set-Variable -Name "subdomain" -Value "YOUR_DOMAIN_HERE"; (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/MHCDatacomm/SyncroSupportForm/master/support_form.ps1','C:\ProgramData\Syncro\live\scripts\support_form.ps1');C:\ProgramData\Syncro\live\scripts\support_form.ps1"
See here for screenshot https://prnt.sc/n6z0w3
-- This will automatically download the script from this repo each time the menu open is clicked. I suggest hosting the script on your own server or repo, as this is in development.
- Option 2 - Manual - Copy this script into the C:\ProgramData\Syncro\live\scripts folder, then insert this into the CMD line of the system tray menu option:
powershell -ExecutionPolicy Bypass "Set-Variable -Name "subdomain" -Value "YOUR_DOMAIN_HERE";C:\ProgramData\Syncro\live\scripts\support_form.ps1"
#>

########################  Load Modules and Stuff  ###################
Add-Type -AssemblyName WindowsBase, PresentationFramework, PresentationCore
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Import-Module $Env:SyncroModule -DisableNameChecking


################### Apply settings based on OS ######################

if ([System.Boolean](Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)) {

    ## Devices Hostname
    $hostname = "$env:computername"

    ## Main Path to Syncro folder
    $syncroFolderPath = "C:/ProgramData/Syncro"

    ## Screenshot Path
    $screenshotPath = "$syncroFolderPath/live/scripts"

    ## Screenshot Disclaimer
    $screenshotDisclaimer = "Note - A screenshot will be added to your ticket to assist with troubleshooting.  Please minimize any sensitive information before clicking Submit."

    ## Grab current logged in user's Name
    $dom = $env:userdomain
    $usr = $env:username
    $currentUser = ([adsi]"WinNT://$dom/$usr,user").fullname

    ## Your Company Name
    $company = (Get-ItemProperty -path 'HKLM:\SOFTWARE\Wow6432Node\RepairTech\Syncro').shop_name

    ## Create shortcut on 'Public' Desktop if you use the -shortcut switch
    if (Test-Path "$env:USERPROFILE\Desktop\Support Request.lnk") {
    	Remove-Item -Path "$env:USERPROFILE\Desktop\Support Request.lnk"
	Write-Host Removing Old Shortcut
    }

    if (Test-Path "$env:PUBLIC\Desktop\Support Request.lnk") {
    	Remove-Item -Path "$env:PUBLIC\Desktop\Support Request.lnk"
	Write-Host Removing Old Shortcut
    }

    if (Test-Path "$env:PUBLIC\Desktop\Request IT Support.lnk") {
	Write-Host Shortcut Exists
    }

    else {
    	Write-Host Creating shortcut

    	$Shell = New-Object -ComObject WScript.Shell
    	$desktopShortcut = $Shell.CreateShortcut($env:PUBLIC + "\Desktop\Request IT Support.lnk")
    	$desktopShortcut.TargetPath = '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe'
    	$desktopShortcut.Arguments = '-ExecutionPolicy Bypass -windowstyle hidden "Set-Variable -Name "subdomain" -Value "' + $subdomain + '' + '";' + $screenshotPath + '/support_form.ps1"'
    	$desktopShortcut.WorkingDirectory = "$screenshotPath"
    	$desktopShortcut.WindowStyle = 1
	$desktopShortcut.Hotkey = "CTRL+SHIFT+Z"
    	$desktopShortcut.IconLocation = "$syncroFolderPath/Images/logo.ico, 0"
    	$desktopShortcut.Description = "Request IT Support"
    	$desktopShortcut.Save()
    }
}
else {
    ## Will need to add more for Linux/Mac functionality later
    # $syncroFolderPath = "./"
}

########################  Form Settings  ############################

## Form Window Title
$formTitle = "Support Request for $company"

$form = New-Object System.Windows.Forms.Form
$form.Icon = "$syncroFolderPath/Images/logo.ico"
$form.Text = "$formTitle"
$form.Size = New-Object System.Drawing.Size(475,475)
$form.StartPosition = 'CenterScreen'
$form.ControlBox = $False
$form.BackColor = 'Ivory'
$form.Font = [System.Drawing.Font]::new("Roboto", 10)

########################  Add Buttons  ##############################

$buttonPanel = New-Object Windows.Forms.Panel
    $buttonPanel.Size = New-Object Drawing.Size @(350,40)
    $buttonPanel.Dock = "Bottom"
    $cancelButton = New-Object Windows.Forms.Button
        $cancelButton.Top = $buttonPanel.Height - $cancelButton.Height - 10; $cancelButton.Left = $buttonPanel.Width - $cancelButton.Width - 10
        $cancelButton.Text = "Cancel"
        $cancelButton.DialogResult = "Cancel"
        $cancelButton.Anchor = "Right"
        $cancelButton.BackColor = "Pink"
        $cancelButton.ForeColor = "Red"

    ## Create the OK button, which will anchor to the left of Cancel
    $okButton = New-Object Windows.Forms.Button
        $okButton.Top = $cancelButton.Top ; $okButton.Left = $cancelButton.Left - $okButton.Width - 5
        $okButton.Text = "Submit"
        $okButton.DialogResult = "Ok"
        $okButton.Anchor = "Right"
        $okButton.BackColor = "MintCream"
        $okButton.Enabled = $False
        # $okButton.Add_Click = ({ $x = $textSubject.Text; $form.Close() })


    ## Add the buttons to the button panel
    $buttonPanel.Controls.Add($okButton)
    $buttonPanel.Controls.Add($cancelButton)

## Add the button panel to the form
$form.Controls.Add($buttonPanel)

## Set Default actions for the buttons
$form.AcceptButton = $okButton          # ENTER = Ok
$form.CancelButton = $cancelButton      # ESCAPE = Cancel

##############################  Labels  ##############################

$labelHost = New-Object System.Windows.Forms.Label
$labelHost.Location = New-Object System.Drawing.Point(10,20)
$labelHost.Size = New-Object System.Drawing.Size(90,20)
$labelHost.Text = 'Device'
$labelHost.Font = [System.Drawing.Font]::new("Roboto", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelHost)

$labelSubject = New-Object System.Windows.Forms.Label
$labelSubject.Location = New-Object System.Drawing.Point(10,60)
$labelSubject.Size = New-Object System.Drawing.Size(90,20)
$labelSubject.Text = 'Subject'
$labelSubject.Font = [System.Drawing.Font]::new("Roboto", 10, [System.Drawing.FontStyle]::Bold)
$labelSubject.ForeColor = 'Red'
$form.Controls.Add($labelSubject)

$labelDesc = New-Object System.Windows.Forms.Label
$labelDesc.Location = New-Object System.Drawing.Point(10,100)
$labelDesc.Size = New-Object System.Drawing.Size(90,40)
$labelDesc.Text = 'Description'
$labelDesc.Font = [System.Drawing.Font]::new("Roboto", 10, [System.Drawing.FontStyle]::Bold)
$labelDesc.ForeColor = 'Red'
$form.Controls.Add($labelDesc)

$labelName = New-Object System.Windows.Forms.Label
$labelName.Location = New-Object System.Drawing.Point(10,200)
$labelName.Size = New-Object System.Drawing.Size(90,20)
$labelName.Text = 'Name'
$labelName.Font = [System.Drawing.Font]::new("Roboto", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelName)

$labelEmail = New-Object System.Windows.Forms.Label
$labelEmail.Location = New-Object System.Drawing.Point(10,240)
$labelEmail.Size = New-Object System.Drawing.Size(90,40)
$labelEmail.Text = 'Email'
$labelEmail.Font = [System.Drawing.Font]::new("Roboto", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($labelEmail)

$labelDisclaimer = New-Object System.Windows.Forms.Label
$labelDisclaimer.Location = New-Object System.Drawing.Point(10,280)
$labelDisclaimer.Size = New-Object System.Drawing.Size(420,50)
$labelDisclaimer.Text = "$screenshotDisclaimer"
$form.Controls.Add($labelDisclaimer)

########################  Input Fields  ########################

$textHost = New-Object System.Windows.Forms.TextBox
$textHost.Location = New-Object System.Drawing.Point(120,20)
$textHost.Size = New-Object System.Drawing.Size(120,20)
$textHost.ReadOnly = $True
$textHost.Text = "$Hostname"
$form.Controls.Add($textHost)

$textSubject = New-Object System.Windows.Forms.TextBox
$textSubject.Location = New-Object System.Drawing.Point(120,60)
$textSubject.Size = New-Object System.Drawing.Size(330,20)
$textSubject.MaxLength = 255
$form.Controls.Add($textSubject)

$textDesc = New-Object System.Windows.Forms.TextBox
$textDesc.Multiline = $True
$textDesc.WordWrap = $True
$textDesc.Location = New-Object System.Drawing.Point(120,100)
$textDesc.Size = New-Object System.Drawing.Size(330,80)
$textDesc.MaxLength = 1000
$textDesc.ScrollBars = 3
$form.Controls.Add($textDesc)

$textName = New-Object System.Windows.Forms.TextBox
$textName.Location = New-Object System.Drawing.Point(120,200)
$textName.Size = New-Object System.Drawing.Size(330,20)
$textName.Text = "$currentUser"
$form.Controls.Add($textName)

$textEmail = New-Object System.Windows.Forms.TextBox
$textEmail.Location = New-Object System.Drawing.Point(120,240)
$textEmail.Size = New-Object System.Drawing.Size(330,20)
$form.Controls.Add($textEmail)

##################  Form Field Validation  ######################

$textSubject.add_TextChanged -and $textDesc.add_TextChanged({ Checkfortext })

function Checkfortext
{
    if ($textSubject.Text.Length -ne 0 -and $textDesc.Text.Length -ne 0)
	{
		$okButton.Enabled = $true
        $labelSubject.Text = 'Subject'
        $labelSubject.ForeColor = 'Black'
        $labelDesc.Text = 'Description'
        $labelDesc.ForeColor = 'Black'
	}
	else
	{
		$okButton.Enabled = $false
        $labelSubject.Text = 'Subject *'
        $labelSubject.ForeColor = 'Red'
        $labelDesc.Text = 'Description *'
        $labelDesc.ForeColor = 'Red'
	}
}

#################################################################

$form.Topmost = $true

$form.Add_Shown({$textSubject.Select()})

$result = $form.ShowDialog()

## Output text from entered fields
$subjectEntry = $textSubject.Text
$descEntry = $textDesc.Text
$nameEntry = $textName.Text
$emailEntry = $textEmail.Text

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
    	## Confirmation box
    	$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
	$wshell.Popup("Ticket Submitted Successfully!`n`nPlease check your email for updates`nand additional information.",10,"This box will close in 10 seconds",64+0)

        #####################  CURRENTLY ONLY ABLE TO UPLOAD TO ASSET.  #####################
        ########  UNCOMMENT 'Upload-File' TO ENABLE UPLOADING SCREENSHOT TO ASSET  ##########

        ## Create ticket
        $ticketOutput = Create-Syncro-Ticket -Subdomain "$Subdomain" -Subject "$subjectEntry - $emailEntry" -IssueType "Submission" -Status "New"

        ## Write the output of the ticket to console, assign it a varaible
        Write-Host $ticketOutput

        ## Grab ticket number from the output
        $ticketNumber = $ticketOutput.ticket.number

        ## Take Screenshot
        $date = Get-Date -f yyyy-MM-dd
        $screenshotName = "scrnsht-ticket $ticketNumber-$date.jpg"
        Get-ScreenCapture -FullFileName "$screenshotPath/$screenshotName"

        ## Upload Screenshot
        Upload-File -Subdomain "$Subdomain" -FilePath "$screenshotPath/$screenshotName"

        ## Add a ticket comment
        Create-Syncro-Ticket-Comment -Subdomain "$Subdomain" -TicketIdOrNumber $ticketNumber -Subject "Issue" -Body "Submitted by $nameEntry $emailEntry - Check the asset $hostname for screenshot - $descEntry" -Hidden $False

        ## Delete screenshot
        Remove-Item "$screenshotPath/$screenshotName"

    }
else
    {
        Write-Host 'Ticket Cancelled'
	$cancelledTicket = 'Ticket Cancelled'
        ## Optionally write cancelled ticket event to Asset as Alert
        ## Comment next line to de-activate
         Rmm-Alert -Category "$cancelledTicket" -Body "User $nameEntry $emailEntry Cancelled a Support Request"
    }

exit
