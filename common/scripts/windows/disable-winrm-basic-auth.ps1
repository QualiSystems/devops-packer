winrm set winrm/config/service '@{AllowUnencrypted="false"}'
winrm set winrm/config/service/auth '@{Basic="false"}'
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
