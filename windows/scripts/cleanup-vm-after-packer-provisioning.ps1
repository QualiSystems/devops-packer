$logPath = Join-Path -Path $Env:windir -ChildPath "packer_log.txt"
Start-Transcript -Path $logPath -Append

. "a:\logger.ps1"

Log-Event "Cleanning up before shutdown"
Log-Event "Block WinRM http with a firewall rule"
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

Log-Event "Run sysprep"
& C:\windows\system32\sysprep\sysprep.exe /generalize /oobe /unattend:C:\Windows\Panther\Unattend\unattend.xml /quiet /shutdown

Stop-Transcript