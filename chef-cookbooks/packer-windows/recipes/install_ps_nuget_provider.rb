powershell_script 'install Nuget package provider' do
  code 'Install-PackageProvider -Name NuGet -Force'
  not_if '(Get-PackageProvider -Name Nuget -ListAvailable -ErrorAction SilentlyContinue) -ne $null'
end