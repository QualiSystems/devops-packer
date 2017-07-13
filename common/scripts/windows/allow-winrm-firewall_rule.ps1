$logPath = Join-Path -Path $Env:windir -ChildPath "packer_log.txt"
Start-Transcript -Path $logPath -Append

Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=allow

Stop-Transcript