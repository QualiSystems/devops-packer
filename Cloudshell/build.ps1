if(-Not (Test-Path ".config")) {
	New-Item ".config" -ItemType Directory
}

if(-Not (Test-Path ".config\packer.cmd")) {
	$PackerPath = Read-Host -Prompt "Enter packer executable full path"
	Add-Content -Path ".config\packer.cmd" -Value "$PackerPath %*";
}

if(-Not (Test-Path ".config\local-variables.json")) {
	
	$Iso_url = Read-Host -Prompt "Enter iso url or nothing to use the default value (download evaluation)"
	
	if(-Not [string]::IsNullOrEmpty($Iso_url)) {
		$json = "{ ""iso_url"": ""$Iso_url""}"
		Add-Content -Path ".config\local-variables.json" -Value $json;
	}
}

. .\.config\packer.cmd build -var-file=".\.config\local-variables.json" $args .\hyperv-cloudshell.json