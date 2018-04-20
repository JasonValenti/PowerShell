<#
Install - Cisco AnyConnect 4.3 w\ Additional cleanup
Author: Jason Valenti
Last Modified Date: 4/20/2018
Rev: 1.12

Description:# This scrpt was developed to provide a solution to cleanup old XML files and legacy hotspot shortcuts on client systems. There are a number of systems still with these shortcuts and profiles.
              This is also intended for the case of upgrading someone who is on a older version or has the vpn client but not the roaming client. This may be uses in a managed install scenario.
#> 

$AppDir = Convert-Path .
$Chassis = Get-WmiObject -class Win32_SystemEnclosure
$Log = "$env:Systemdrive\ATS\logs\CiscoAnyConnect\install43.txt"
$LogDir = "$env:Systemdrive\ATS\Logs\CiscoAnyConnect\"
$ErrorActionPreference = "Stop"
$MsiPackages = ("anyconnect-win-4.3.02039-pre-deploy-k9.msi","anyconnect-umbrella-win-4.3.02039-pre-deploy-k9.msi")
$XmlProfile = "ATS_VPNOpenDNS.xml"
$ProfileDir = "$env:Systemdrive\programdata\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\"
$HotSpotScript = "$env:Systemdrive\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Public Hotspot Login.vbs"
$ExistingShortcuts = @(Get-ChildItem -Path $env:Systemdrive\users -Filter "PUBLIC HOTSPOT LOGIN.lnk" -Recurse -force -ErrorAction SilentlyContinue | Select-Object FullName)
$ExistingProfiles = @(Get-ChildItem -Path $ProfileDir -Filter "*.xml" -Recurse -force -ErrorAction SilentlyContinue | Where-Object {$_.Name -ne $XmlProfile}) | Select-Object FullName

#Load external functions
. "$AppDir\Functions.ps1"

Check-LogDir
Check-LogFile

#Scan through registry for install programs that match "Umbrella Roaming Client". This is the legacy roaming client before it was intigrated with cisco anyconnect.
$VersionsInstalled = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, UninstallString | Where-Object {$_.DisplayName -match "Umbrella Roaming Client"}
If($VersionsInstalled)
{
    foreach($Version in $VersionsInstalled)
    {
        #Run the uninstall command + silient + logging 
        "$(Get-TimeStamp) [Warning] Umbrella Client version $($Version.DisplayVersion) detected. Begining removal..." | Write-Warning
        $Uninstallstring = $Version.UninstallString
        $Uninstallstring = $UninstallString.Substring($UninstallString.IndexOf('/X'))

        try
        {
            $Install = Start-Process $env:Systemdrive\windows\system32\msiexec.exe -ArgumentList "$UninstallString /qn /lv+ $log" -wait -PassThru
            $ExitCode = $Install.ExitCode
            Check-ExitCode
            
        }
        catch
        {Write-Error}
    }
}else {"$(Get-TimeStamp) [STATUS] No legacy Roaming clients detected...." | Write-Log}

#Scan trhough Profles and delete any that do not equal the correct profile.
if($ExistingProfiles)
{
    foreach($File in $ExistingProfiles -ne $XmlProfile)
    {
        "$(get-timestamp) [WARNING] Removing Bad Profile: $($file.Fullname)" | Write-Warning
        Try
        {
            Remove-Item -Path $file.FullName -ErrorAction stop
        }
        catch
        {
        Write-Error
        }
    }
}
else
{
    "$(Get-TimeStamp) [STATUS] No bad prodifles found, moving on..." | Write-Log
}

#Run through cleanup of hot spot login script
if(Test-path $HotSpotScript)
{
    "$(Get-TimeStamp) [WARNING] Removing old HotSpot Script: $HotSpotScript" | Write-Warning
    Remove-Item $HotSpotScript -Force -ErrorAction stop
}

#Delete Existing Hotspot Shortcuts
"$(get-timestamp) [STATUS] Checking for 'PUBLIC HOTSPOT LOGIN.lnk' shortcuts..."| Write-Log
if($ExistingShortcuts)
{
    foreach($file in $ExistingShortcuts)
    {
        "$(get-timestamp) [Warning] Removing Shortcut: $($file.Fullname)" | Write-Warning
        Try
        {Remove-Item -Path $file.FullName -ErrorAction stop}
        catch
        {Write-Error}
    }
}
else
{
    "$(get-timestamp) [STATUS] Cannot find any exisiting 'PUBLIC HOTSPOT LOGIN.lnk' shortcuts..."| Write-Log
}

#Install Cisco VPN and Roaming Client
Foreach($package in $MsiPackages)
{
    Try{
        $Install = start-Process $env:Systemdrive\windows\system32\msiexec.exe -ArgumentList "/qn /i $package /lv+ $log" -wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode
        }
        catch{Write-Error}
}   

#Copy XML and Launch vonui.exe
Try{ 
    "$(Get-TimeStamp) [STATUS] Copying XML and Umbrella OrgInfo...." | Write-Log
    Copy-Item .\ATS_VPNOpenDNS.xml -Destination "$ProfileDir" *>> $Log 
    Copy-Item .\OrgInfo.json -Destination "$env:Systemdrive\programdata\cisco\Cisco AnyConnect Secure Mobility Client\Umbrella\" *>> $Log

    "$(Get-TimeStamp) [STATUS] Starting vpnui.exe....." | Write-log
    Start-Process "$env:Systemdrive\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe" *>> $Log       
    }
    Catch{Write-Error}

"End of script!" | Write-log