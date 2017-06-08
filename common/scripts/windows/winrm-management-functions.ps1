function Add-WinRMFirewallRule()
{
    netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
}

function Set-WinRMBasicAuthentication()
{
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
}

function Set-WinRMFirewallRuleToBlock()
{
    netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
}

function Reset-WinRMBasicAuthentication()
{
    winrm set winrm/config/service '@{AllowUnencrypted="false"}'
    winrm set winrm/config/service/auth '@{Basic="false"}'
}