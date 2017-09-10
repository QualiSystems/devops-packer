script = <<-EOH
  (Get-PackageProvider -Name Nuget -ListAvailable -ErrorAction SilentlyContinue) -ne $null
EOH

describe powershell(script) do
  its('strip') { should cmp 'true' }
end