$ErrorActionPreference = 'Stop'
#Requires -RunAsAdministrator
# choco-install.ps1 Copyleft 2021-2023 by Bill Curran AKA BCURRAN3
# LICENSE: GNU GPL v3 - https://www.gnu.org/licenses/gpl.html
# Open a GitHub issue at https://github.com/bcurran3/ChocolateyPackages/issues if you have suggestions for improvement.

Write-Host "Choco-Install.ps1 v0.0.7 (2023/05/10) - Install Chocolatey packages with enhanced options" -Foreground White
Write-Host "Copyleft 2021-2023 Bill Curran (bcurran3@yahoo.com) - free for personal and commercial use`n" -Foreground White

# Verify ChocolateyToolsLocation was created by Get-ToolsLocation during install and is in the environment
if (!($env:ChocolateyToolsLocation)) {$env:ChocolateyToolsLocation = "$env:SystemDrive\tools"}
if (!(Test-Path "$env:ChocolateyToolsLocation\BCURRAN3\choco-upgrade-all.config")) {Write-Warning "Configuration not found. Please re-install.";throw}

# Import preferences from choco-upgrade-all.config
[xml]$ConfigFile = Get-Content "$env:ChocolateyToolsLocation\BCURRAN3\choco-upgrade-all.config"
$ConfigArguments         = $ConfigFile.Settings.Preferences.ConfigArguments
$DebugLogging            = $ConfigFile.Settings.Preferences.DebugLogging
$DeleteNewDesktopIcons   = $ConfigFile.Settings.Preferences.DeleteNewDesktopIcons
$DeleteNewStartMenuIcons = $ConfigFile.Settings.Preferences.DeleteNewStartMenuIcons
$PreProcessScript        = $ConfigFile.Settings.Preferences.PreProcessScript
$PostProcessScript       = $ConfigFile.Settings.Preferences.PostProcessScript

$IconsDeleted=0

# Set Notepad++ as preferred editor/viewer
if (Test-Path $env:ChocolateyInstall\bin\notepad++.exe){
     $Editor="notepad++.exe"
    } else {
      $Editor="notepad.exe"
    }

# Easily edit the config file
if ($args -eq "-EditConfig") {
    Write-Host "  ** Editing contents of choco-upgrade-all.config." -Foreground Magenta
	&$Editor "$env:ChocolateyToolsLocation\BCURRAN3\choco-upgrade-all.config"
	return
}

# Run pre-processor if configured
if ($PreProcessScript){&$PreProcessScript}

# get existing Desktop and Start Menu icons
$UserDesktopIconsPre     = Get-ChildItem -Path "$env:USERPROFILE\Desktop\*.lnk"
if ($UserDesktopIconsPre -eq $null) {$UserDesktopIconsPre=0}
$PublicDesktopIconsPre   = Get-ChildItem -Path "$env:PUBLIC\Desktop\*.lnk"
if ($PublicDesktopIconsPre -eq $null) {$PublicDesktopIconsPre=0}
$UserStartMenuIconsPre   = Get-ChildItem -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\*.lnk" -Recurse
if ($UserStartMenuIconsPre -eq $null) {$UserStartMenuIconsPre=0}
$PublicStartMenuIconsPre = Get-ChildItem -Path "$env:ProgramData\Microsoft\Windows\Start Menu\*.lnk" -Recurse
if ($PublicStartMenuIconsPre -eq $null) {$PublicStartMenuIconsPre=0}

# Do the Chocolatey Humpty Hump
Start-Process -NoNewWindow -FilePath "$env:ChocolateyInstall\bin\choco.exe" -ArgumentList "install -y $ConfigArguments $args" -Wait

# get existing and new Desktop and Start Menu icons
$UserDesktopIconsPost     = Get-ChildItem -Path "$env:USERPROFILE\Desktop\*.lnk"
if ($UserDesktopIconsPost -eq $null) {$UserDesktopIconsPost=0}
$PublicDesktopIconsPost   = Get-ChildItem -Path "$env:PUBLIC\Desktop\*.lnk"
if ($PublicDesktopIconsPost -eq $null) {$PublicDesktopIconsPost=0}
$UserStartMenuIconsPost   = Get-ChildItem -Path "$env:AppData\Microsoft\Windows\Start Menu\Programs\*.lnk" -Recurse
if ($UserStartMenuIconsPost -eq $null) {$UserStartMenuIconsPost=0}
$PublicStartMenuIconsPost = Get-ChildItem -Path "$env:ProgramData\Microsoft\Windows\Start Menu\*.lnk" -Recurse
if ($PublicStartMenuIconsPost -eq $null) {$PublicStartMenuIconsPost=0}

# Delete new Desktop icons if configured to do so
if ($DeleteNewDesktopIcons -eq 'True'){
	if ($UserDesktopIconsPre.count -ne '0' -and $UserDesktopIconsPost.count -ne '0'){
       $IconsNew = Compare-Object -ReferenceObject ($UserDesktopIconsPre) -DifferenceObject ($UserDesktopIconsPost) -PassThru
       if ($IconsNew -ne $null) {
		    Remove-Item $IconsNew.fullname
			$IconsDeleted=$IconsDeleted + $IconsNew.count
	    }
	}
	if ($PublicDesktopIconsPre.count -ne '0' -and $PublicDesktopIconsPost.count -ne '0'){
       $IconsNew = Compare-Object -ReferenceObject ($PublicDesktopIconsPre) -DifferenceObject ($PublicDesktopIconsPost) -PassThru
       if ($IconsNew -ne $null) {
		   Remove-Item $IconsNew.fullname
		   $IconsDeleted=$IconsDeleted + $IconsNew.count
		}
    }
}
# Delete new Start Menu icons if configured to do so
if ($DeleteNewStartMenuIcons -eq 'True'){
	if ($UserStartMenuIconsPre.count -ne '0' -and $UserStartMenuIconsPost.count -ne '0'){
       $IconsNew = Compare-Object -ReferenceObject ($UserStartMenuIconsPre) -DifferenceObject ($UserStartMenuIconsPost) -PassThru
       if ($IconsNew -ne $null) {
		   Remove-Item $IconsNew.fullname
		   $IconsDeleted=$IconsDeleted + $IconsNew.count
		}
	   }
	if ($PublicStartMenuIconsPre.count -ne '0' -and $PublicStartMenuIconsPost.count -ne '0'){
       $IconsNew = Compare-Object -ReferenceObject ($PublicStartMenuIconsPre) -DifferenceObject ($PublicStartMenuIconsPost) -PassThru
       if ($IconsNew -ne $null) {
		   Remove-Item $IconsNew.fullname
		   $IconsDeleted=$IconsDeleted + $IconsNew.count
		}
    }
}

# Run post-processor if configured
if ($PostProcessScript){&$PostProcessScript}

Write-Host "`n  ** Choco-Install DELETED $IconsDeleted unwanted icon(s).`n" -ForegroundColor Magenta
Write-Host "Found Choco-Install.ps1 useful?" -ForegroundColor White
Write-Host "Buy me a beer at https://www.paypal.me/bcurran3donations" -ForegroundColor White
Write-Host "Become a patron at https://www.patreon.com/bcurran3" -ForegroundColor White