if(Test-Path "c:\windows\temp\chef.msi") {
  Write-Host "Uninstall Chef..."
  Start-Process MSIEXEC.exe '/uninstall c:\windows\temp\chef.msi /quiet' -Wait
}