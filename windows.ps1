<#

#OPTIONAL			
    	[Environment]::SetEnvironmentVariable("BoxStarter:DataDrive", "C", "Machine") # for reboots
	[Environment]::SetEnvironmentVariable("BoxStarter:DataDrive", "C", "Process") # for right now

    	[Environment]::SetEnvironmentVariable("BoxStarter:SourceCodeFolder", "VSO", "Machine") # relative path to for reboots
	[Environment]::SetEnvironmentVariable("BoxStarter:SourceCodeFolder", "VSO", "Process") # for right now
#START
	START http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/AddedInnovation/developer-setup/master/windows.ps1
#>

$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $false
$Boxstarter.AutoLogin = $true

$checkpointPrefix = 'BoxStarter:Checkpoint:'

function Get-CheckpointName {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointName
    )
    return "$checkpointPrefix$CheckpointName"
}

function Set-Checkpoint {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointName,

        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointValue
    )

    $key = Get-CheckpointName $CheckpointName
    [Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Machine") # for reboots
    [Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Process") # for right now
}

function Get-Checkpoint {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointName
    )

    $key = Get-CheckpointName $CheckpointName
    [Environment]::GetEnvironmentVariable($key, "Process")
}

function Clear-Checkpoints {
    $checkpointMarkers = Get-ChildItem Env: | where { $_.name -like "$checkpointPrefix*" } | Select -ExpandProperty name
    foreach ($checkpointMarker in $checkpointMarkers) {
        [Environment]::SetEnvironmentVariable($checkpointMarker, '', "Machine")
        [Environment]::SetEnvironmentVariable($checkpointMarker, '', "Process")
    }
}

function Use-Checkpoint {
    param(
        [string]
        $CheckpointName,

        [string]
        $SkipMessage,

        [scriptblock]
        $Function
    )

    $checkpoint = Get-Checkpoint -CheckpointName $CheckpointName

    if (-not $checkpoint) {
        $Function.Invoke($Args)

        Set-Checkpoint -CheckpointName $CheckpointName -CheckpointValue 1
    }
    else {
        Write-BoxstarterMessage $SkipMessage
    }
}

function Get-OSInformation {
    $osInfo = Get-WmiObject -class Win32_OperatingSystem `
        | Select-Object -First 1

    return ConvertFrom-String -Delimiter \. -PropertyNames Major, Minor, Build  $osInfo.version
}

function Test-IsOSWindows10 {
    $osInfo = Get-OSInformation

    return $osInfo.Major -eq 10
}

function Get-SystemDrive {
    return $env:SystemDrive[0]
}

function Get-DataDrive {
    $driveLetter = Get-SystemDrive

    if ((Test-Path env:\BoxStarter:DataDrive) -and (Test-Path $env:BoxStarter:DataDrive)) {
        $driveLetter = $env:BoxStarter:DataDrive
    }

    return $driveLetter
}

function Install-WindowsUpdate {
    if (Test-Path env:\BoxStarter:SkipWindowsUpdate) {
        return
    }

    Enable-MicrosoftUpdate
    Install-WindowsUpdate -AcceptEula
    #if (Test-PendingReboot) { Invoke-Reboot }
}

function Install-WebPackage {
    param(
        $packageName,
        [ValidateSet('exe', 'msi')]
        $fileType,
        $installParameters,
        $downloadFolder,
        $url,
        $filename
    )

    if ([String]::IsNullOrEmpty($filename)) {
        $filename = Split-Path $url -Leaf
    }

    $fullFilename = Join-Path $downloadFolder $filename

    if (test-path $fullFilename) {
        Write-BoxstarterMessage "$fullFilename already exists"
        return
    }

    Get-ChocolateyWebFile $packageName $fullFilename $url
    Install-ChocolateyInstallPackage $packageName $fileType $installParameters $fullFilename
}

function Install-WebPackageWithCheckpoint {
    param(
        $packageName,
        [ValidateSet('exe', 'msi')]
        $fileType,
        $installParameters,
        $downloadFolder,
        $url,
        $filename
    )

    Use-Checkpoint `
        -Function ${Function:Install-WebPackage} `
        -CheckpointName $packageName `
        -SkipMessage "$packageName is already installed" `
        $packageName `
        $fileType `
        $installParameters `
        $downloadFolder `
        $url `
        $filename
}

function Install-CoreApps {
    choco install googlechrome          --limitoutput
    choco install notepadplusplus	--limitoutput    
    choco install 7zip			--limitoutput
    choco install adobereader           --limitoutput
    choco install lastpass		--limitoutput
    choco install filezilla		--limitoutput    
    choco install powershell		--limitoutput
    choco install ditto			--limitoutput
    choco install greenshot		--limitoutput
    choco install openvpn		--limitoutput
    choco install dropbox		--limitoutput
    #trend micro TBD
}

function Set-ChocoCoreAppPins {
    # pin apps that update themselves
    choco pin add -n=googlechrome
}

function Install-SqlTools {
    param (
        $DownloadFolder
    )

    choco install sql-server-management-studio --limitoutput

    #Install-WebPackageWithCheckpoint 'SQL Source Control V3.8' 'exe' '/quiet' $DownloadFolder ftp://support.red-gate.com/patches/SQLSourceControlFrequentUpdates/23Jul2015/SQLSourceControlFrequentUpdates_3.8.21.179.exe
    #Install-WebPackageWithCheckpoint 'SQL Compare V11.6' 'exe' '/quiet' $DownloadFolder http://download.red-gate.com/checkforupdates/SQLCompare/SQLCompare_11.6.11.2463.exe
}

function Install-CoreDevApps {
    choco install dotnetcore-sdk    		--limitoutput
    choco install nuget.commandline		--limitoutput        
    choco install nugetpackageexplorer		--limitoutput    
    choco install fiddler4            		--limitoutput
    choco install postman			--limitoutput
    choco install powershell   			--limitoutput
    choco install sql-server-management-studio	--limitoutput
    choco install awscli			--limitoutput
    choco install awstools.powershell		--limitoutput
}

function Install-VisualStudio2017 {
    # install visual studio 2017 community and extensions
    choco install visualstudio2017community				--limitoutput	
    choco install visualstudio2017-workload-netcoretools		--limitoutput
    choco install visualstudio2017-workload-manageddesktop		--limitoutput
    choco install visualstudio2017-workload-netweb			--limitoutput
    choco install visualstudio2017-workload-visualstudioextension	--limitoutput
    choco install visualstudio2017-workload-azure			--limitoutput
}

function Install-InternetInformationServices {
    # Enable Internet Information Services Feature - will enable a bunch of things by default
    choco install IIS-WebServerRole                 --source windowsfeatures --limitoutput

    # Web Management Tools Features
    choco install IIS-ManagementScriptingTools      --source windowsfeatures --limitoutput
    choco install IIS-IIS6ManagementCompatibility   --source windowsfeatures --limitoutput # installs IIS Metbase

    # Common Http Features
    choco install IIS-HttpRedirect                  --source windowsfeatures --limitoutput

    # .NET Framework 4.5/4.6 Advance Services
    choco install NetFx4Extended-ASPNET45           --source windowsfeatures --limitoutput # installs ASP.NET 4.5/4.6

    # Application Development Features
    choco install IIS-NetFxExtensibility45          --source windowsfeatures --limitoutput # installs .NET Extensibility 4.5/4.6
    choco install IIS-ISAPIFilter                   --source windowsfeatures --limitoutput # required by IIS-ASPNET45
    choco install IIS-ISAPIExtensions               --source windowsfeatures --limitoutput # required by IIS-ASPNET45
    choco install IIS-ASPNET45                      --source windowsfeatures --limitoutput # installs support for ASP.NET 4.5/4.6
    choco install IIS-ApplicationInit               --source windowsfeatures --limitoutput

    # Health And Diagnostics Features
    choco install IIS-LoggingLibraries              --source windowsfeatures --limitoutput # installs Logging Tools
    choco install IIS-RequestMonitor                --source windowsfeatures --limitoutput
    choco install IIS-HttpTracing                   --source windowsfeatures --limitoutput
    choco install IIS-CustomLogging                 --source windowsfeatures --limitoutput

    # Performance Features
    choco install IIS-HttpCompressionDynamic        --source windowsfeatures --limitoutput

    # Security Features
    choco install IIS-BasicAuthentication           --source windowsfeatures --limitoutput
    choco install IIS-WindowsAuthentication     --source windowsfeatures --limitoutput   
}

function Set-RegionalSettings {
    #http://stackoverflow.com/questions/4235243/how-to-set-timezone-using-powershell
    &"$env:windir\system32\tzutil.exe" /s "Central Standard Time"    
}

function Set-BaseSettings {
    Update-ExecutionPolicy -Policy Unrestricted

    $sytemDrive = Get-SystemDrive
    Set-Volume -DriveLetter $sytemDrive -NewFileSystemLabel "OS"
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar
    Set-TaskbarOptions -Combine Never

    # replace command prompt with powershell in start menu and win+x
    Set-CornerNavigationOptions -EnableUsePowerShellOnWinX
}

function Set-UserSettings {
    choco install taskbar-never-combine             --limitoutput
    choco install explorer-show-all-folders         --limitoutput
    choco install explorer-expand-to-current-folder --limitoutput
}

function Set-BaseDesktopSettings {
    if (Test-IsOSWindows10) {
        return
    }

    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
}

function Set-DevDesktopSettings {
    if (Test-IsOSWindows10) {
        return
    }

    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
}

function Move-WindowsLibrary {
    param(
        $libraryName,
        $newPath
    )

    if (-not (Test-Path $newPath)) {
        Move-LibraryDirectory -libraryName $libraryName -newPath $newPath
    }
}

function New-SourceCodeFolder {
    $sourceCodeFolder = 'VSO'
    if (Test-Path env:\BoxStarter:SourceCodeFolder) {
        $sourceCodeFolder = $env:BoxStarter:SourceCodeFolder
    }

    if ([System.IO.Path]::IsPathRooted($sourceCodeFolder)) {
        $sourceCodePath = $sourceCodeFolder
    }
    else {
        $drivePath = Get-DataDrive
        $sourceCodePath = Join-Path "$drivePath`:" $sourceCodeFolder
    }

    if (-not (Test-Path $sourceCodePath)) {
        New-Item $sourceCodePath -ItemType Directory
    }
}

function New-InstallCache {
    param
    (
        [String]
        $InstallDrive
    )

    $tempInstallFolder = Join-Path $InstallDrive "temp\install-cache"

    if (-not (Test-Path $tempInstallFolder)) {
        New-Item $tempInstallFolder -ItemType Directory
    }

    return $tempInstallFolder
}

function Enable-ChocolateyFeatures {
    choco feature enable --name=allowGlobalConfirmation
}

function Disable-ChocolateyFeatures {
    choco feature disable --name=allowGlobalConfirmation
}

function Update-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

$dataDriveLetter = Get-DataDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive

Use-Checkpoint -Function ${Function:Set-RegionalSettings} -CheckpointName 'RegionalSettings' -SkipMessage 'Regional settings are already configured'

Write-BoxstarterMessage "Windows update..."
#Install-WindowsUpdate

# disable chocolatey default confirmation behaviour (no need for --yes)
Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName 'IntializeChocolatey' -SkipMessage 'Chocolatey features already configured'

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
