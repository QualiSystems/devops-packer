%w{xNetworking xRemoteDesktopAdmin}.each do |ps_module|
  powershell_script "install #{ps_module} module" do
    code "Install-Module #{ps_module} -Force"
    not_if "(Get-Module #{ps_module} -list) -ne $null"
  end
end

dsc_resource "Enable RDP" do
  resource :xRemoteDesktopAdmin
  property :UserAuthentication, "Secure"
  property :ensure, "Present"
end

dsc_resource "Allow RDP firewall rule" do
  resource :xfirewall
  property :name, "Remote Desktop"
  property :ensure, "Present"
  property :enabled, "True"
end