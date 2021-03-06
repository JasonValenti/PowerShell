<#
Repair - KACE Agents
Modified by - Jason Valenti
Last Modified Date - 5/1/2018
Rev: 1.00

Description:#  This script was delveloped to resolve the issues experienced after upgrading KACE. After upgrading KACE to version 8.0 there was a defect causing systems to be 
               connected to the appliance but never check in. After working with support for some time the agent cannot replace the old kbot 4 files to do proper inventory. This
               script will delete the \ProgramData\dell\KACE\kbots_cache\packages\kbots\4 direcotry on the target system and run a force invenotry using psexec (runkbot.exe 4 0).
#>

#Defined varriables
$AppDir = Convert-Path .
$Log = "$env:Systemdrive\ATS\logs\KACE\AgentReapir.log"
$LogDir = "$env:Systemdrive\ATS\Logs\KACE\"
$ErrorActionPreference = "Continue"
$computernames = Get-Content 'C:\ATS\ComputerList.txt'
$SucessfullMachinesList = "$logDir\Sucessfull.log"

#Load external functions
. "$AppDir\Functions.ps1"

Check-LogDir
Check-LogFile

#Run the following code for each computer name found in the computer names varible. This variable is collected from a local text file.
foreach ($computer in $computernames) 
{
        #Test if he machine is reachable before running any further code, if not move on to the next
        if (Test-Connection $computer -count 2 -Quiet)
        {  
                "$(Get-TimeStamp) [STATUS] $Computer is online!" | Write-Log
                "$(Get-TimeStamp) [STATUS] Deleting the KBOT 4 direcotry on $computer" | Write-Log

                #Delete the kbot\4 directory that is holding up the invenotry, agent will pull this down again at next inventory
                try{Remove-Item -Path \\$computer\c$\ProgramData\dell\KACE\kbots_cache\packages\kbots\4 -Recurse -Force -ErrorAction Stop}
                catch
                {
                        "$(Get-TimeStamp) [ERROR] Could not delete the kbot 4 direcotry on $computer" | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
                        "$(Get-TimeStamp) [Status] Moving to next compuer..." | Write-Log
                        Continue
                }
                <#
                
                "$(Get-TimeStamp) [STATUS] KBOT 4 sucessfull removed, forcing inventory on $computer" | Write-Log

                After a scussful delete of the KBOT 4 direcotry force an inventory and pull the down the lastes inventory script (4 being the inventory script, 0 being pull the latest)
                try{& psexec.exe \\$computer "c:\Program Files (x86)\Dell\KACE\runkbot.exe" 4 0 >> $log}
                catch
                {
                        "$(Get-TimeStamp) [ERROR] kbot did not exit successfully." | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
                }
                
                #>
                "$(Get-TimeStamp) [STATUS] Repair Complete on $computer" | Write-Log
                "$(Get-TimeStamp) [STATUS] Check KACE for inventory Status" | Write-Log
        }
        else
        {
                "$(Get-TimeStamp) [ERROR] $computer is offline...Moving on to next host" | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
        }
 }