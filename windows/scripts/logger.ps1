function Log-Event([string]$message, [string]$entryType="Information") {
	$logName = "Packer Provisioning"
	$logSourceName = GCI $MyInvocation.PSCommandPath | Select -Expand Name

	Write-EventLog -LogName $logName -Source $logSourceName -EventID "104" -EntryType $entryType -Message $message
	Write-Host "$logSourceName - $entryType : $message"
}