REM change port number in below command.
REM Use citrix vda command line helper tool from citrix. https://support.citrix.com/article/CTX234824 if needed
REM Install new VDA agent, delete files and scheduled tasks. Finally reboot.
 
C:\software\vdaupgrade\VDAServerSetup_1912.exe /masterpvsimage /virtualmachine /components VDA /controllers "DDC1 DDC2 DDC3" /noreboot /quiet /disableexperiencemetrics /enable_hdx_ports /enable_hdx_udp_ports /enable_real_time_transport /enable_remote_assistance
C:\Windows\system32\schtasks.exe /delete /tn VDAInstall /f
del c:\software\vdaupgrade\VDAServerSetup_1912.exe /F
C:\Windows\System32\timeout.exe /t 5
C:\Windows\System32\shutdown.exe /r /t 20 /f
del c:\software\vdaupgrade\install.bat /F