# Windows Developer Automation
Development environment set-up scripts.

Log into the computer with an Added Innovation domain account.

~~~~
Set-ExecutionPolicy Unrestricted
~~~~

wget -Uri 'https://raw.githubusercontent.com/AddedInnovation/developer-setup/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -InstallDev -SkipWindowsUpdate }
