param(
	[int]$MaxWindowsUpdateRestarts=0,
	[string]$UserName="vagrant",
	[string]$Password="vagrant",
	[string]$ScriptPath = $MyInvocation.MyCommand.Path
)

function Install-PSWindowsUpdate {
	if((Get-Module PSWindowsUpdate -list) -eq $null) {
		Install-Module PSWindowsUpdate -Force
	}
}

function Set-AutoLogon {
	$registryKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"    		
	$domain = $env:USERDNSDOMAIN	
	
	Log-Event "Auto logon domain name is: $domain user name: $UserName"

	Set-ItemProperty -Path $registryKey -Name "AutoAdminLogon" -Value "1"
	
	if(-not [string]::IsNullOrEmpty($domain)) {		
		Set-ItemProperty -Path $registryKey -Name "DefaultDomainName" -Value $domain
	}
	else { 
		Remove-ItemProperty -Path $registryKey -Name "DefaultDomainName" -ErrorAction SilentlyContinue
	}
	
	Set-ItemProperty -Path $registryKey -Name "DefaultUserName" -Value $UserName
	Set-ItemProperty -Path $registryKey -Name "DefaultPassword" -Value $Password
}

function Remove-AutoLogon {
	$registryKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

	Remove-ItemProperty -Path $registryKey -Name "AutoAdminLogon" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path $registryKey -Name "DefaultDomainName" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path $registryKey -Name "DefaultPassword" -ErrorAction SilentlyContinue
}

function Set-ScriptToRunAndReboot {
	$registryKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    $registryEntry = "InstallWindowsUpdates"
		
	Set-ItemProperty -Path $registryKey -Name $registryEntry -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File $ScriptPath -MaxWindowsUpdateRestarts $($MaxWindowsUpdateRestarts - 1) -UserName $UserName -Password $Password"

	Log-Event "Restarting"
	Restart-Computer -Force

	exit 105
}

function Log-Event([string]$message, [string]$entryType="Information") {
	Write-EventLog -LogName $logName -Source $logSourceName -EventID "104" -EntryType $entryType -Message $Message
}

try {
	$logName = "Packer Provisioning"
	$logSourceName = $MyInvocation.MyCommand.ToString()

	New-EventLog -Source $logSourceName -LogName $logName -ErrorAction SilentlyContinue

	Log-Event "Install windows update script. MaxWindowsUpdateRestarts: $MaxWindowsUpdateRestarts"

	if($MaxWindowsUpdateRestarts -ile 0) {
		Log-Event "MaxWindowsUpdateRestarts reached. Count is: $MaxWindowsUpdateRestarts"
		exit 0
	}
	
	Log-Event "Removing auto logon registry keys"
	Remove-AutoLogon

	if((Get-PackageProvider -Name Nuget -ListAvailable -ErrorAction SilentlyContinue) -eq $null) {
		Log-Event "Installing Nuget package provider"
		Install-PackageProvider -Name NuGet -Force
	}

	Log-Event "Installing windows updates module"
	Install-PSWindowsUpdate

	Log-Event "Installing windows updates"
	Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot

	if((Get-WURebootStatus -Silent) -eq "True") {
		Log-Event "Setting auto logon registry keys"
		Set-AutoLogon

		Log-Event "Setting startup script registry keys"
		Set-ScriptToRunAndReboot
	}
}
catch {
	Log-Event "Exception thrown: $($_.Exception)" "Error"
	Write-Host "Exception thrown: $($_.Exception)"
}