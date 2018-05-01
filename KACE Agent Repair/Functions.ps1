<#
Functions
Author: Jason Valenti
Last Modified Date: 8/17/2017
Rev: 1.05

Description: This script defines all the nesecry logging functions used in K2000 post install tasks. This script lines up with the ScriptTemplate.ps1 script 
#> 

#region Define MSI Check-ExitCode
Function Check-ExitCode
{
    if($ExitCode -eq 0 -or $Exitcode -eq 3010)
    {"$(Get-TimeStamp) [STATUS] Install Scuessfull with MSI exitcode: $Exitcode" | Write-Log}
    Else
    {
        "$(Get-TimeStamp) [ERROR] Install failed with MSI exitcode: $Exitcode" | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
        "$(Get-TimeStamp) [ERROR] End Script. See $log for details." | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
        Exit($ExitCode)
    }  
}
#endregion
#region Define Get-TimeStap Function
function Get-TimeStamp
{
    Return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)   
}
#endregion
#region Define Write-Error Function (Red)
function Write-Error
{
    
    "$(Get-TimeStamp) [ERROR] Exception Caught:" | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
    "$(Get-TimeStamp) [ERROR] Exception Type: $($_.Exception.GetType().FullName)" | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
    "$(Get-TimeStamp) [ERROR] Exception Message: $($_.Exception.Message)" | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
    "$(Get-TimeStamp) [ERROR] End Script. See $log for details." | %{write-host -ForegroundColor Red  $_; out-file -filepath $log -inputobject $_ -append}
    if($LastExitCode -ne 0)
    {
      Exit($LastExitCode)
    }
    else
    {Exit(1)}
}
#endregion

#Define Write-Log Function (Green), Capture from pipeline and write to host and log
function Write-Log
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        $piped
    )
       #%{write-host -foregroundcolor DarkYellow $_; out-file -filepath $log -inputobject $_ -append}
       Write-Host $piped -foregroundcolor Green
       out-file -filepath $log -inputobject $piped -append
}

#Define Caution Log Function (Dark Yellow), Capture from pipeline and write to host and log 
function Write-Warning
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        $piped
    )
       #%{write-host -foregroundcolor DarkYellow $_; out-file -filepath $log -inputobject $_ -append}
       Write-Host $piped -foregroundcolor DarkYellow
       out-file -filepath $log -inputobject $piped -append
}

#region Define Logging directory check
function Check-LogDir
{
    if(!(Test-Path $LogDir))
    {
        try
        {
            New-Item -ItemType Directory -Path $LogDir -ErrorAction Stop
            "$(Get-TimeStamp) [Warning] Log Folder has been created..." | Write-Warning
        }
        catch
        {
            Write-Error
        }
    }
    else
    {
        "$(Get-TimeStamp) [STATUS] Log Folder exists, continuing to confirm log file...." | Write-log
    }
}
#endregion

#region Check if log file is presnet and create it
function Check-LogFile
{
    if(!(Test-Path $log))
    {
        try
        {
            New-Item -ItemType File -Path $log -ErrorAction Stop
            "$(Get-TimeStamp) [Warning] Log File has been created..." | Write-Warning
        }
        catch
        {
            Write-Error
        }
    }
    else
    {
        "$(Get-TimeStamp) [STATUS] Log file exists, Continuing to Install..." | Write-log
    }
 }
#endregion