param(
	[int]$MaxWindowsUpdateRestarts=3,
	[string]$UserName="vagrant",
	[string]$Password="vagrant"
)

$logPath = Join-Path -Path $Env:windir -ChildPath "packer_log.txt"
Start-Transcript -Path $logPath -Append

Write-Host "Installing windows updates"
$scriptPath = $($MyInvocation.MyCommand.Path)
$scriptFolder = Split-Path $scriptPath

Push-Location $scriptFolder
. .\win-updates.ps1 -ScriptPath $scriptPath -UserName $UserName -Password $Password -MaxWindowsUpdateRestarts $MaxWindowsUpdateRestarts
Pop-Location

if($lastexitcode -ne $null -and $lastexitcode -ne 0) {	
	if($lastexitcode -eq 105) {
		Write-Host "Rebooting after win updates"
		exit 0
	}
	
	exit $lastexitcode
}

Write-Host "Enabling WinRM for Packer usage"

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