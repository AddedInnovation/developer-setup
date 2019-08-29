
#
#	Visual Studio 2019 Enterprise
#
choco install visualstudio2019enterprise				
choco install visualstudio2019-workload-netcoretools	
choco install visualstudio2019-workload-manageddesktop	
choco install visualstudio2019-workload-netweb			
choco install visualstudio2019-workload-visualstudioextension
choco install visualstudio2019-workload-azure

#
#	TODO Add all recommended extensions for VS 2019
#
choco install chocolatey-visualstudio.extension

Update-SessionEnvironment

Install-ChocolateyVsixPackage "PowerShellTools" https://marketplace.visualstudio.com/_apis/public/gallery/publishers/AdamRDriscoll/vsextensions/PowerShellToolsforVisualStudio2017-18561/4.9.1/vspackage