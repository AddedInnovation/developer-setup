

function New-SourceCodeFolder {
    param(
        [string]
        $FolderName
    )
    
    $sourceCodeFolder = $FolderName
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

function Get-DataDrive {
    $driveLetter = Get-SystemDrive

    if ((Test-Path env:\BoxStarter:DataDrive) -and (Test-Path $env:BoxStarter:DataDrive)) {
        $driveLetter = $env:BoxStarter:DataDrive
    }

    return $driveLetter
}

function Get-SystemDrive {
    return $env:SystemDrive[0]
}

New-SourceCodeFolder -FolderName "VSO"
New-SourceCodeFolder -FolderName "Git"

#
#	File explorer settings
#

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar

choco install taskbar-never-combine             
choco install explorer-show-all-folders         
choco install explorer-expand-to-current-folder

Update-ExecutionPolicy -Policy Unrestricted

$sytemDrive = Get-SystemDrive
Set-Volume -DriveLetter $sytemDrive -NewFileSystemLabel "OS"

#Set-TaskbarOptions -Combine Never
Enable-RemoteDesktop

Disable-InternetExplorerESC

#
# Replace command prompt with PowerShell in start menu and Win+X
#
Set-CornerNavigationOptions -EnableUsePowerShellOnWinX
