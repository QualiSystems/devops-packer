. "a:\logger.ps1"

$chef = Get-WmiObject -Class Win32_product -Filter "Name LIKE '%Chef Client%'"

if($chef) {
	Log-Event "Uninstall Chef..."
	$chef.Uninstall()
}