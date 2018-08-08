function Create-EventLogIfNedded([string]$logSourceName) {
	if(-not $([System.Diagnostics.EventLog]::Exists("Packer Provisioning") -and [System.Diagnostics.EventLog]::SourceExists($logSourceName)))	{
		New-EventLog -Source $logSourceName -LogName $logName -ErrorAction SilentlyContinue
	}
}

function Log-Event([string]$message, [string]$entryType="Information") {
	$logName = "Packer Provisioning"
	$logSourceName = GCI $MyInvocation.PSCommandPath | Select -Expand Name

	Create-EventLogIfNedded $logSourceName

	Write-EventLog -LogName $logName -Source $logSourceName -EventID "104" -EntryType $entryType -Message $message
	Write-Host "$logSourceName - $entryType : $message"
}