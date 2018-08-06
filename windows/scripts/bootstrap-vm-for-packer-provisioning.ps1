param(
	[int]$MaxWindowsUpdateRestarts=3,
	[string]$UserName="vagrant",
	[string]$Password="vagrant"
)

$logPath = Join-Path -Path $Env:windir -ChildPath "packer_log.txt"
Start-Transcript -Path $logPath -Append

$scriptPath = $($MyInvocation.MyCommand.Path)
$scriptFolder = Split-Path $scriptPath

. "a:\logger.ps1"

Log-Event "Installing windows updates"

Push-Location $scriptFolder
. .\win-updates.ps1 -ScriptPath $scriptPath -UserName $UserName -Password $Password -MaxWindowsUpdateRestarts $MaxWindowsUpdateRestarts
Pop-Location

if($lastexitcode -ne $null -and $lastexitcode -ne 0) {	
	if($lastexitcode -eq 105) {
		Log-Event "Rebooting after win updates"
		exit 0
	}
	
	exit $lastexitcode
}

Log-Event "Enabling WinRM for Packer usage"

Log-Event "Iterating network profiles and setting their network category to private"
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

Log-Event "Calling Enable-PSRemoting"
Enable-PSRemoting

Log-Event "Enabling WinRM basic authentication"
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

Log-Event "Adding new firewall exception for WinRM http"
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

Stop-Transcript