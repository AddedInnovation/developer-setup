#
#	Description: Added Innovation Developer Boxstarter Script
#	Author: Mark Whisler
#	Company: Added Innovation
# 
#	Installs core company and development tools for a .NET developer and VS Enterprise subscriber
#
#
#	Big thanks to https://github.com/microsoft/windows-dev-box-setup-scripts
#

Disable-UAC
$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $false
$Boxstarter.AutoLogin = $true
$ConfirmPreference = "None" #ensure installing PowerShell modules don't prompt on needed dependencies

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/scripts"

Write-host "Script base URI is $helperUri"

function ExecuteScript {
    Param ([string]$script)
    Write-host "Executing $helperUri/$script ..."
	iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}

#	
#	Set up Windows
#
ExecuteScript "SystemSettings.ps1";
ExecuteScript "RemoveWindowsApps.ps1";

#
#	Set up Added Core
#
ExecuteScript "AddedCoreApps.ps1";
ExecuteScript "AddedCoreDev.ps1";

Update-SessionEnvironment

ExecuteScript "VisualStudio.ps1"

if (Test-PendingReboot) { Invoke-Reboot }

Update-SessionEnvironment

#
#	Setup IIS
#
ExecuteScript "IIS.ps1"

if (Test-PendingReboot) { Invoke-Reboot }

#
#	Setup SQL Server
#
ExecuteScript "SQL.ps1"

if (Test-PendingReboot) { Invoke-Reboot }
#
#	Resume and Install Updates
#
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
