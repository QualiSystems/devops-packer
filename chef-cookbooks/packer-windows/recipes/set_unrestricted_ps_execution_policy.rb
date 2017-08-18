script = <<-EOH
  Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force -ErrorAction SilentlyContinue
  Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction SilentlyContinue
EOH

powershell_script 'set powershell execution policy to unrestricted' do
  code script
  not_if '(Get-ExecutionPolicy -Scope LocalMachine) -eq [Microsoft.PowerShell.ExecutionPolicy]::Unrestricted'
end