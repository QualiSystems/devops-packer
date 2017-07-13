function New-WinRMFirewallException {
	netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
}

function Set-WinRMFirewallRuleToBlock
{
    netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
}

function Enable-WinRMBasicAuth {
    winrm set winrm/config/client/auth '@{Basic="true"}'
	winrm set winrm/config/service/auth '@{Basic="true"}'
	winrm set winrm/config/service '@{AllowUnencrypted="true"}'
}