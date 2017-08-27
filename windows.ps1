
Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdate

# disable chocolatey default confirmation behaviour (no need for --yes)
Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName 'IntialiseChocolatey' -SkipMessage 'Chocolatey features already configured'

Use-Checkpoint -Function ${Function:Set-BaseSettings} -CheckpointName 'BaseSettings' -SkipMessage 'Base settings are already configured'
Use-Checkpoint -Function ${Function:Set-UserSettings} -CheckpointName 'UserSettings' -SkipMessage 'User settings are already configured'

Write-BoxstarterMessage "Starting installs"

Use-Checkpoint -Function ${Function:Install-CoreApps} -CheckpointName 'InstallCoreApps' -SkipMessage 'Core apps are already installed'

# pin chocolatey app that self-update
Use-Checkpoint -Function ${Function:Set-ChocoCoreAppPins} -CheckpointName 'ChocoCoreAppPins' -SkipMessage 'Core apps are already pinned'

Use-Checkpoint -Function ${Function:Set-BaseDesktopSettings} -CheckpointName 'BaseDesktopSettings' -SkipMessage 'Base desktop settings are already configured'

Write-BoxstarterMessage "Installing dev apps"

#enable dev related windows features

#setup iis
Use-Checkpoint -Function ${Function:Install-InternetInformationServices} -CheckpointName 'InternetInformationServices' -SkipMessage 'IIS features are already configured'

#install sql tools
Use-Checkpoint -Function ${Function:Install-SqlTools} -CheckpointName 'SqlTools' -SkipMessage 'SQL Tools are already installed'

if (Test-PendingReboot) { Invoke-Reboot }

#install vs2017
Use-Checkpoint -Function ${Function:Install-VisualStudio2017} -CheckpointName 'VisualStudio2017' -SkipMessage 'Visual Studio 2017 is already installed'

#install core apps needed for dev
Use-Checkpoint -Function ${Function:Install-CoreDevApps} -CheckpointName 'CoreDevApps' -SkipMessage 'Core dev apps are already installed'

# make folder for source code
New-SourceCodeFolder

# pin chocolatey app that self-update
Use-Checkpoint -Function ${Function:Set-ChocoDevAppPins} -CheckpointName 'ChocoDevAppPins' -SkipMessage 'Dev apps are already pinned'

Use-Checkpoint -Function ${Function:Set-DevDesktopSettings} -CheckpointName 'DevDesktopSettings' -SkipMessage 'Dev desktop settings are already configured'

# install chocolatey as last choco package
choco install chocolatey --limitoutput

# re-enable chocolatey default confirmation behaviour
Use-Checkpoint -Function ${Function:Disable-ChocolateyFeatures} -CheckpointName 'DisableChocolatey' -SkipMessage 'Chocolatey features already configured'

if (Test-PendingReboot) { Invoke-Reboot }

# reload path environment variable
Update-Path

# set HOME to user profile for git
[Environment]::SetEnvironmentVariable("HOME", $env:UserProfile, "User")

# rerun windows update after we have installed everything
Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdate

Clear-Checkpoints
