. a:\winrm-management-functions.ps1

Remove-WinRMBasicAuthentication
Set-WinRMFirewallRuleToBlock

C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:C:/Windows/Panther/Unattend/unattend.xml /quiet /shutdown