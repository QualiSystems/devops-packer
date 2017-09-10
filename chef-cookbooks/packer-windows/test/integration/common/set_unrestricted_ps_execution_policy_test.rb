script = <<-EOH
  (Get-ExecutionPolicy -Scope LocalMachine) -eq [Microsoft.PowerShell.ExecutionPolicy]::Unrestricted
EOH

describe powershell(script) do
  its('strip') { should cmp 'true' }
end