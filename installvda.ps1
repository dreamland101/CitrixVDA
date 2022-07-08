# Base VDA removal / reinstall script. This uses Powershell ISE on 5.1 with needing to be ran with account with rights in VMware and on the target server as well as the module for PowerCLI. 
# Modified from https://github.com/ChayScripts/Citrix-VDA-Upgrade-Scripts scripts. Added snapshot for VMware and a report of previous versions.
 
$vdalist = get-content "C:\pathtotextfilewithfqdnservernames.txt"
$source = "placewherefilesarestored\vdaupgrade"
$dest = "c$\software\vdaupgrade"
$date = Get-Date -Format MMddyyyy
$report = @()
 
  foreach ($vda in $vdalist) {
    $line = "" | Select Name, PreviousVersion, SnapShot
    $vda1 = ($vda.split('.')[0])
    $line.Name = "$vda"
    $line.PreviousVersion = (invoke-command -ComputerName $vda -ScriptBlock {Get-WmiObject -Class Win32_Product | where name -match "Citrix Virtual Desktop Agent - x64" | select Name,Version}).Version
    $snapshot = (get-vm $vda1  | new-snapshot -name $date-$vda1-preupgrade)
    $line.SnapShot = (get-vm $vda1 | get-snapshot).name
    Write-Host "Working on $vda"
    if (!(Test-Path -Path \\$vda\c$\software\vdaupgrade)) {
        New-Item -ItemType Directory -Path \\$vda\c$\software -Name vdaupgrade
        Copy-Item "\\$source\install.bat" -Destination \\$vda\$dest -Force
        Copy-Item "\\$source\remove.bat" -Destination \\$vda\$dest -Force
        Copy-Item "\\$source\VDAServerSetup_1912.exe" -Destination \\$vda\$dest -Force
    }
    else {
        Copy-Item "\\$source\install.bat" -Destination \\$vda\$dest -Force
        Copy-Item "\\$source\remove.bat" -Destination \\$vda\$dest -Force
        Copy-Item "\\$source\VDAServerSetup_1912.exe" -Destination \\$vda\$dest -Force
 
    }
    Invoke-Command -ComputerName $vda -Scriptblock {
        $time = (Get-Date).AddMinutes(3)
        $action = New-ScheduledTaskAction -Execute 'c:\software\vdaupgrade\remove.bat'
        $trigger = New-ScheduledTaskTrigger -Once -At $time
        $principal = New-ScheduledTaskPrincipal  -RunLevel Highest -UserID "NT AUTHORITY\SYSTEM" -LogonType S4U
 
        Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "VDAUninstall" -Description "Citrix VDA Uninstall" 
    }
 
    Invoke-Command -ComputerName $vda -Scriptblock {
        $action = New-ScheduledTaskAction -Execute 'c:\software\vdaupgrade\install.bat'
        $trigger = New-ScheduledTaskTrigger -AtStartup 
        $principal = New-ScheduledTaskPrincipal  -RunLevel Highest -UserID "NT AUTHORITY\SYSTEM" -LogonType S4U
 
        Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "VDAInstall" -Description "Citrix VDA Install" 
 
    } 
 
    $report += $line
 
  }
 
$report | export-csv c:\scripts\logs\$date-vda-upgrades.csv -Append -NoTypeInformation