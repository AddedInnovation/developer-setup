
#
#	Visual Studio 2022 Enterprise
#
choco install visualstudio2022enterprise
choco install visualstudio2022-workload-manageddesktop	
choco install visualstudio2022-workload-netweb			
choco install visualstudio2022-workload-visualstudioextension
choco install visualstudio2022-workload-azure
choco install visualstudio2022-workload-data

Install-ChocolateyVsixPackage "MicrosoftReportProjectsforVisualStudio2022" "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ProBITools/vsextensions/MicrosoftReportProjectsforVisualStudio2022/3.0.7/vspackage"

Update-SessionEnvironment

#
# VS Code
#
choco install vscode
