$vdilist = get-content c:\scripts\logs\servers.txt
$source = "\\placewherefilesare"
$dest = "c$\software\vdaupgrade"
 
  foreach($vdi in $vdilist){
    Write-Host "Working on $vdi"
    if (!(Test-Path -Path \\$vdi\c$\software\vdaupgrade)) {
        New-Item -ItemType Directory -Path \\$vdi\c$\software -Name vdaupgrade
        Copy-Item "\\$source\install.bat" -Destination \\$vdi\$dest -Force
        Copy-Item "\\$source\baseinstall.bat" -Destination \\$vdi\$dest -Force
        Copy-Item "\\$source\VDAServerSetup_1912.exe" -Destination \\$vdi\$dest -Force
    }
    else {
        Copy-Item "\\$source\install.bat" -Destination \\$vdi\$dest -Force
        Copy-Item "\\$source\baseinstall.bat" -Destination \\$vdi\$dest -Force
        Copy-Item "\\$source\VDAServerSetup_1912.exe" -Destination \\$vdi\$dest -Force
    }
   
    $rdsCheck = (invoke-command -ComputerName $vdilist -ScriptBlock {get-windowsfeature | where name -like "rds-rd-server" | select InstallState })
 
    if($rdsCheck.InstallState.value -eq "Available") {
         
        Copy-Item "\\$source\baseinstall.bat" -Destination \\$vdi\$dest -Force
         
        Invoke-Command -ComputerName $vdi -Scriptblock {
          $action = New-ScheduledTaskAction -Execute 'c:\software\vdaupgrade\install.bat'
          $trigger = New-ScheduledTaskTrigger -AtStartup
          $principal = New-ScheduledTaskPrincipal  -RunLevel Highest -UserID "NT AUTHORITY\SYSTEM" -LogonType S4U
          $taskName = "VDAInstall"
          $taskDescription = "Citrix VDA Install"
 
        Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description $taskDescription
        }
         
        Invoke-Command -ComputerName $vdi -Scriptblock {
          $time = (Get-Date).AddMinutes(7)
          $action = New-ScheduledTaskAction -Execute 'c:\software\vdaupgrade\baseinstall.bat'
          $trigger = New-ScheduledTaskTrigger -Once -At $time
          $principal = New-ScheduledTaskPrincipal  -RunLevel Highest -UserID "NT AUTHORITY\SYSTEM" -LogonType S4U
          $taskName = "BaseInstall"
          $taskDescription = "Base Software Install"
 
        Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description $taskDescription
        }
 
        Invoke-Command -ComputerName $vdi -ScriptBlock {
          Add-WindowsFeature rds-rd-server
          Restart-computer
        }
    }
    
 
  }