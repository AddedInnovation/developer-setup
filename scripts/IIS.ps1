#
#	Install and configure IIS
#

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
choco install IIS-WindowsAuthentication         --source windowsfeatures --limitoutput