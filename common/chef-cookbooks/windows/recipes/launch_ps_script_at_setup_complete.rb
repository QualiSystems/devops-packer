directory "C:/Windows/setup/scripts" do
  recursive true
end

file_path = node['script_path']

remote_file "Create setup complete script" do
  source  !file_path || file_path.empty? ? "file:///A:/allow-winrm-firewall_rule.ps1" : file_path
  path "C:/Windows/setup/scripts/SetupComplete.ps1"
end

file "Create setup complete PowerShell script" do
	content "START /wait PowerShell.exe -ExecutionPolicy Bypass -Command \"& C:/Windows/setup/scripts/SetupComplete.ps1\" "
	path "C:/Windows/setup/scripts/SetupComplete.cmd"
end