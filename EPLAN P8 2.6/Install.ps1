<#
Install - Eplan P8 v2.6
Modified by - Jason Valenti
Last Modified Date - 4/30/2018
Rev: 1.12

Description:# This script is a ported over from the origonal batch file provided via EPLAN. This script will install EPLAN P8 v2.6 on the machine that its run on. Note that this
              deployment could take up to 20+ minutes. The hotfix patch on lines 94 - 97 takes up the most time in this installation. 
#>

#Defined varriables
$AppDir = Convert-Path .
$Log = "$env:Systemdrive\ATS\logs\Eplan\install.log"
$LogDir = "$env:Systemdrive\ATS\Logs\Eplan\"
$ErrorActionPreference = "Stop"
$ESS_USERPROFILE="$env:Systemdrive\Users\Public"
$ESS_Path=$env:ProgramFiles
$ESS_EECONEPath=$env:ProgramFiles
$ESS_BITF=" (X64)"
$ESS_BITM=" (X64)"
$ESS_USERPROFILE="$env:Systemdrive\Users\Public"
$BSB="64 Bit"
$Arch = (Get-CimInstance Win32_operatingsystem).OSArchitecture #Environment variable could not be used as running under KACE context cause it to return 32-bit when it was really 64.

#Load external functions
. "$AppDir\Functions.ps1"

Check-LogDir
Check-LogFile

#Report running environment - This is used to report back if the powershell is running as 32-bit or 64-bit. This is vauleable infromation when running powershell from KACE.
$Running64 = [Environment]::Is64BitProcess
"$(Get-TimeStamp) [STATUS] Running 64-bit: $Running64" | Write-Log


#Check if system is 32-bit and if not then exit and fail script
"$(Get-TimeStamp) [STATUS] System architecture is: $Arch" | Write-Log
if ($Arch -match '32' -or $Arch -match '86')
{
    "$(Get-TimeStamp) [ERROR] System Architecture is 32-bit, this version of ePLAN does not support 32-bit Systems" | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
    Exit(1)

}

#Disaplay the paths being used in the installation. This was passed over from the origional batch install. (Troubleshooting purposes)
    "$(Get-TimeStamp) [STATUS] The following directory paths are being used:" | Write-Log
                     "------------------------------------------------------" | Write-Log
                     "Program directory: $ESS_Path\EPLAN" | Write-Log
                     "Installations data directory: C:\ProgramData\EPLAN\O_Data" | Write-Log
                     "System master data: C:\Users\Public\EPLAN\Data" | Write-Log
                     "User settings: $ESS_USERPROFILE\EPLAN\SETTINGS" | Write-Log
                     "Company settings: $ESS_USERPROFILE\EPLAN\SETTINGS" | Write-Log
                     "Workstation settings: $ESS_USERPROFILE\EPLAN\SETTINGS" | Write-Log
                     "------------------------------------------------------" | Write-Log

#Begining of installation, install each component and check its msi exit code for either a 0 or 3010(restart requried).
"$(Get-TimeStamp) [STATUS] Installation will now begin..." | Write-Log
try{
    "$(Get-TimeStamp) [STATUS] Installing License client(Win32)...." | Write-Log
        $Install = Start-Process "$AppDir\License Client (Win32)\setup.exe" -ArgumentList "/q /L 1033" -wait -passthru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    "$(Get-TimeStamp) [STATUS] Instlling License Client(x64)...." | Write-Log
        $Install = Start-Process "$AppDir\License Client (x64)\setup.exe" -ArgumentList "/q /L 1033" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    "$(Get-TimeStamp) [STATUS] Installing Eplan Platform 2.6...." | Write-Log
        $Install = Start-Process msiexec.exe -ArgumentList "/i `"$AppDir\Platform$ESS_BITF\EPLAN Platform 2.6$ESS_BITM.msi`" ESS_CMDSYSTEMROOT=`"$ESS_PATH\EPLAN\Platform\`" ESS_CMDDATAROOT=`"C:\ProgramData\EPLAN\O_Data\Platform\`" ESS_CMDDATAROOTWRK=`"C:\Users\Public\EPLAN\Data`" ESS_CMDCOMPANYSETTINGS=`$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDSTATIONSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDUSERSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDCOMPANYCODE=`"ATS_IEC`" ESS_CMDMEASUREMENT=`"mm`" ESS_CMDONLINEHELP=`"0`" ESS_CMDUILANGUAGES=`"1033;1031;1036`" ESS_CMDHELPLANGUAGES=`"1033;1031;1036`" ESS_CMDDATATYPES=`"`" /qn" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    "$(Get-TimeStamp) [STATUS] Installing Eplan Platform Data 2.6...." | Write-Log
        $Install = Start-Process msiexec.exe "/i `"$AppDir\Platform Add-on$ESS_BITF\EPLAN Platform Data 2.6$ESS_BITM.msi`" ESS_CMDSYSTEMROOT=`"$ESS_PATH\EPLAN\Platform Data\`" ESS_CMDDATAROOT=`"C:\ProgramData\EPLAN\O_Data\Platform Data\`" ESS_CMDDATAROOTWRK=`"C:\Users\Public\EPLAN\Data`" ESS_CMDCOMPANYSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDSTATIONSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDUSERSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDCOMPANYCODE=`"ATS_IEC`" ESS_CMDMEASUREMENT=`"mm`" ESS_CMDONLINEHELP=`"0`" ESS_CMDUILANGUAGES=`"1033;1031;1036`" ESS_CMDHELPLANGUAGES=`"1033;1031;1036`" ESS_CMDDATATYPES=`"`" /qn" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    "$(Get-TimeStamp) [STATUS] Installing Eplan Fluid Data 2.6...." | Write-Log
        $Install = Start-Process msiexec.exe -ArgumentList "/i `"$AppDir\Fluid Add-on$ESS_BITF\EPLAN Fluid Data 2.6$ESS_BITM.msi`" ESS_CMDSYSTEMROOT=`"$ESS_PATH\EPLAN\Fluid Data\`" ESS_CMDDATAROOT=`"C:\ProgramData\EPLAN\O_Data\Fluid Data\`" ESS_CMDDATAROOTWRK=`"C:\Users\Public\EPLAN\Data`" ESS_CMDCOMPANYSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDSTATIONSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDUSERSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDCOMPANYCODE=`"ATS_IEC`" ESS_CMDMEASUREMENT=`"mm`" ESS_CMDONLINEHELP=`"0`" ESS_CMDUILANGUAGES=`"1033;1031;1036`" ESS_CMDHELPLANGUAGES=`"1033;1031;1036`" ESS_CMDDATATYPES=`"`" /qn" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    <#
    This was commented out in the origonal batch script. No point converting unless needed.
    %MSIE%"$AppDir\Fluid$ESS_BITF\EPLAN Fluid 2.6$ESS_BITM.msi" TRANSFORMS="1033.mst" ESS_CMDSYSTEMROOT="$ESS_PATH\EPLAN\Fluid\" ESS_CMDDATAROOT="C:\ProgramData\EPLAN\O_Data\Fluid\" ESS_CMDDATAROOTWRK="C:\Users\Public\EPLAN\Data" ESS_CMDCOMPANYSETTINGS="$ESS_USERPROFILE\EPLAN\SETTINGS\Fluid" ESS_CMDSTATIONSETTINGS="$ESS_USERPROFILE\EPLAN\SETTINGS\Fluid" ESS_CMDUSERSETTINGS="$ESS_USERPROFILE\EPLAN\SETTINGS\Fluid" ESS_CMDCOMPANYCODE="ATS_IEC" ESS_CMDMEASUREMENT="mm" ESS_CMDONLINEHELP="0" ESS_CMDUILANGUAGES="1033;1031;1036" ESS_CMDHELPLANGUAGES="1033;1031;1036" ESS_CMDDATATYPES="" /qn
    #>

    "$(Get-TimeStamp) [STATUS] Installing Eplan Electric P8 Data 2.6...." | Write-Log
        $Install = Start-Process msiexec.exe -ArgumentList "/i `"$AppDir\Electric P8 Add-on$ESS_BITF\EPLAN Electric P8 Data 2.6$ESS_BITM.msi`" ESS_CMDSYSTEMROOT=`"$ESS_PATH\EPLAN\Electric P8 Data\`" ESS_CMDDATAROOT=`"C:\ProgramData\EPLAN\O_Data\Electric P8 Data\`" ESS_CMDDATAROOTWRK=`"C:\Users\Public\EPLAN\Data`" ESS_CMDCOMPANYSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDSTATIONSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDUSERSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS`" ESS_CMDCOMPANYCODE=`"ATS_IEC`" ESS_CMDMEASUREMENT=`"mm`" ESS_CMDONLINEHELP=`"0`" ESS_CMDUILANGUAGES=`"1033;1031;1036`" ESS_CMDHELPLANGUAGES=`"1033;1031;1036`" ESS_CMDDATATYPES=`"`" /qn" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    "$(Get-TimeStamp) [STATUS] Installing Eplan Electic P8 2.6...." | Write-Log
        $Install = Start-Process msiexec.exe -ArgumentList "/i `"$AppDir\Electric P8$ESS_BITF\EPLAN Electric P8 2.6$ESS_BITM.msi`" TRANSFORMS=`"1033.mst`" ESS_CMDSYSTEMROOT=`"$ESS_PATH\EPLAN\Electric P8\`" ESS_CMDDATAROOT=`"C:\ProgramData\EPLAN\O_Data\Electric P8\`" ESS_CMDDATAROOTWRK=`"C:\Users\Public\EPLAN\Data`" ESS_CMDCOMPANYSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS\Electric P8`" ESS_CMDSTATIONSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS\Electric P8`" ESS_CMDUSERSETTINGS=`"$ESS_USERPROFILE\EPLAN\SETTINGS\Electric P8`" ESS_CMDCOMPANYCODE=`"ATS_IEC`" ESS_CMDMEASUREMENT=`"mm`" ESS_CMDONLINEHELP=`"0`" ESS_CMDUILANGUAGES=`"1033;1031;1036`" ESS_CMDHELPLANGUAGES=`"1033;1031;1036`" ESS_CMDDATATYPES=`"`" /qn" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    "$(Get-TimeStamp) [STATUS] Installing Platform Hotfix...." | Write-Log
        $Install = Start-Process msiexec.exe -ArgumentList "/p `"$AppDir\Platform Hotfix$ESS_BITF\EPLAN Platform 2.6 (x64) HF2 10582.msp`" /qn" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode

    "$(Get-TimeStamp) [STATUS] Installing Eplan Help en-us 2.6...." | Write-Log
        $Install = Start-Process msiexec.exe -ArgumentList "/i `"$AppDir\Platform Help$ESS_BITF\EPLAN Help en-US 2.6$ESS_BITM.msi`" INSTALLLEVEL=`"999`" /qn" -Wait -PassThru
        $ExitCode = $Install.ExitCode
        Check-ExitCode
    }
    catch{Write-Error}

#Display end of installation message for seucessfull deployment
"------------------------------------------------------" | Write-Log
"$(Get-TimeStamp) [STATUS] Install Successfull. Script Complete !" | Write-Log
"------------------------------------------------------" | Write-Log
