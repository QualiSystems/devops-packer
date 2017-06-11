function Log([string]$message) {
	Write-Host $message
	Add-Content "C:\Windows\Panther\packer-log.txt" $message
}

try
{
	Log "Starting bootstrap"
	. a:\winrm-management-functions.ps1

	Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
	Enable-PSRemoting
	Set-WinRMBasicAuthentication
	
	Log "Finished bootstrap"
}
catch
{
	Log $Exception
}