# Windows Developer Automation
Development environment set-up scripts.

First check to see if Chocolatey is operating: https://status.chocolatey.org/

Next, run this in Powershell

```powershell
Set-ExecutionPolicy Unrestricted

wget -Uri 'https://raw.githubusercontent.com/AddedInnovation/developer-setup/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -InstallDev -SkipWindowsUpdate }

```
