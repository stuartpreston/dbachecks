## To Test performance - I pull the dbatools docker repo and cd to the samples/stackoverflow Directory

## I changed the ports because I have some of them already running SQL

##     line 17   - "7401:1433"
##     line 34   - "7402:1433"
##     line 52   - "7403:1433"

#then docker compose up -d

# cd to the root of dbachecks and checkout the pesterv5 branch

# 

$Checks = 'DefaultTrace', 'OleAutomationProceduresDisabled', 'CrossDBOwnershipChaining', 'ScanForStartupProceduresDisabled', 'RemoteAccessDisabled', 'SQLMailXPsDisabled', 'DAC', 'OLEAutomation'
Compare-CheckRuns -Checks $checks
function Compare-CheckRuns {
param($Checks)
$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password
$Sqlinstances = 'localhost,7401', 'localhost,7402', 'localhost,7403'

$originalCode = {
    Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $Checks -SqlCredential $cred -legacy $true -Show None
}

$NewCode = {
    Invoke-DbcCheck -SqlInstance $Sqlinstances -Check $Checks -SqlCredential $cred -legacy $false  -Show None
}

$originalCodetrace = Trace-Script -ScriptBlock $originalCode
$NewCodetrace = Trace-Script -ScriptBlock $NewCode

$originalCodeMessage = "With original Code it takes {0} MilliSeconds" -f $originalCodetrace.StopwatchDuration.TotalMilliseconds


$savingMessage = "
Running with {3} Checks against 3 SQL Containers

With original Code it takes {1} Seconds
With New Code it takes {4} Seconds

New Code for these checks is saving 
{0} seconds from a run of {1} seconds
New Code runs in {2} % of the time
" -f ('{0:N2}' -f ($originalCodetrace.StopwatchDuration.TotalSeconds - $NewCodetrace.StopwatchDuration.TotalSeconds)),('{0:N2}' -f $originalCodetrace.StopwatchDuration.TotalSeconds),('{0:N2}' -f (($NewCodetrace.StopwatchDuration.TotalSeconds/$originalCodetrace.StopwatchDuration.TotalSeconds) * 100)),($Checks -split ',' -join ',') ,('{0:N2}' -f $NewCodetrace.StopwatchDuration.TotalSeconds)
cls

Write-PSFMessage -Message $savingMessage -Level Output
}