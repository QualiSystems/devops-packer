$logPath = Join-Path -Path $Env:windir -ChildPath "packer_log.txt"
Start-Transcript -Path $logPath -Append

Write-Host "Enabling WinRM for Packer usage"

. a:\winrm-management-functions.ps1

Write-Host "Iterating network profiles and setting their network category to private"
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

Write-Host "Calling Enable-PSRemoting"
Enable-PSRemoting

Write-Host "Enabling WinRM basic authentication"
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

Write-Host "Adding new firewall exception for WinRM http"
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

Stop-Transcript