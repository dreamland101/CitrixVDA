@ECHO ON
change user /install
REM pause
timeout 5
 
net localgroup "Remote Desktop Users" /add "domain1\domain users" "domain2\domain users"
REM pause
timeout 5
 
REG IMPORT C:\software\mode.reg
REM pause
timeout 5
 
C:\software\AcrobatRdrDC\setup.exe /sAll /ini Setup.ini
REM pause
timeout 10
 
cd C:\software\MS-Edge
powershell -File ".\Install-Edge.ps1" -MSIName "MicrosoftEdgeEnterpriseX64.msi" -ChannelID "{56eb18f8-b008-4cbd-b6d2-8c97fe7e9062}" -DoAutoUpdate "True"
REM pause
timeout 5
 
msiexec.exe /i "C:\software\Google-Chrome\64B\GoogleChromeStandaloneEnterprise64.msi" /qn
REM pause
timeout 5
 
C:\software\Office\setup.exe /config .\ProPlus.WW\config.xml /adminfile CITRIX.MSP
REM pause
timeout 10
 
change user /execute
REM pause
timeout 5
 
C:\Windows\system32\schtasks.exe /delete /tn BaseInstall /f
C:\Windows\System32\timeout.exe /t 5
C:\Windows\System32\shutdown.exe /r /t 20 /f
del c:\software\vdaupgrade\baseinstall.bat /F