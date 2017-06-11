function Log([object]$message) {
	Write-Host $message
	Add-Content "C:\Windows\Panther\packer-log.txt" $message
}

try {
#. a:\winrm-management-functions.ps1

#Remove-WinRMBasicAuthentication
#Set-WinRMFirewallRuleToBlock

C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:C:/Windows/Panther/Unattend/unattend.xml /quiet /shutdown

}
catch {
	Log $_.Exception
	throw $_.Exception
}