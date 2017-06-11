function Set-WinRMBasicAuthentication
{
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
}

function Set-WinRMFirewallRuleToBlock
{
    netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
}

function Remove-WinRMBasicAuthentication
{
    winrm set winrm/config/service '@{AllowUnencrypted="false"}'
    winrm set winrm/config/service/auth '@{Basic="false"}'
}