[CmdletBinding(DefaultParameterSetName="build")]
param
(

	[parameter(Position=0, ParameterSetName="clean", Mandatory=$true, HelpMessage="Clean all build output, boxes, logs and chef dependencied and kitchen folders")]
	[Switch]$Clean,
	
	[parameter(Position=1, ParameterSetName="clean", Mandatory=$false, HelpMessage="Clear packer cache (this is where the iso file is saved so it will be downloaded/copied at the next build)")]
	[Switch]$IncludePackerCache,
	
	[parameter(Position=0, ParameterSetName="build", Mandatory=$true, HelpMessage="One of the box variable json file names (without extension) in the boxes subdirectories`nYou can also run .\make.ps1 -List to see all available boxes")]
	[parameter(Position=0, ParameterSetName="validate", Mandatory=$true, HelpMessage="One of the box variable json file names (without extension) in the boxes subdirectories`nYou can also run .\make.ps1 -List to see all available boxes")]
	[parameter(Position=0, ParameterSetName="inspect", Mandatory=$true, HelpMessage="One of the box variable json file names (without extension) in the boxes subdirectories`nYou can also run .\make.ps1 -List to see all available boxes")]
	[string]$BoxName,

	[parameter(ParameterSetName="inspect")]
	[switch]$Inspect,	
	
	[parameter(ParameterSetName="validate")]
	[switch]$Validate,
	
	[parameter(ParameterSetName="build")]
	[parameter(ParameterSetName="validate")]
	[parameter(ParameterSetName="inspect")]
	[switch]$Reconfigure,

	[parameter(ParameterSetName="build")]
	[parameter(ParameterSetName="validate")]
	[parameter(ParameterSetName="inspect")]
	[switch]$Logging,

	[parameter(ParameterSetName="list")]
	[switch]$List,

	[parameter(ParameterSetName="build", ValueFromRemainingArguments=$true)]
	[parameter(ParameterSetName="validate", ValueFromRemainingArguments=$true)]
	[parameter(ParameterSetName="inspect", ValueFromRemainingArguments=$true)]
	[string[]]$RemainingArguments
)

#region Script variables

$makeCommand = $PsCmdlet.ParameterSetName

$cookbooksFolder = "..\chef-cookbooks";
$windowsCookbooksPath = "$cookbooksFolder\chef-windows"
$ubuntuCookbooksPath = "$cookbooksFolder\chef-ubuntu"

$windowsBaseTemplate = (Get-Item ".\windows\windows_base_template.json").FullName
$ubuntuHyperVBaseTemplate = (Get-Item ".\linux\ubuntu\hyperv\ubuntu.json").FullName
$ubuntuDockerBaseTemplate = (Get-Item ".\linux\ubuntu\docker\docker_ubuntu.json").FullName

$boxBaseTemplateMappedToBoxVariableFiles = 
@(
	@{ Template = $windowsBaseTemplate ; Boxes = Get-ChildItem -Path ".\windows\boxes"; ChefCookbooksFolder = $windowsCookbooksPath },
	@{ Template = $ubuntuHyperVBaseTemplate ; Boxes = Get-ChildItem -Path ".\linux\ubuntu\hyperv\boxes"; ChefCookbooksFolder = $ubuntuCookbooksPath},
	@{ Template = $ubuntuDockerBaseTemplate ; Boxes = Get-ChildItem -Path ".\linux\ubuntu\docker\boxes"; ChefCookbooksFolder = $ubuntuCookbooksPath};
)

$selectedTemplateVsBoxes = $boxBaseTemplateMappedToBoxVariableFiles | ? { ($_.Boxes | % { $_.BaseName }) -contains $BoxName }

$packerTemplateFile = $selectedTemplateVsBoxes.Template
$boxVariablesFile = ($selectedTemplateVsBoxes | % { $_.Boxes } | ? { $_.BaseName -eq $BoxName }).FullName

#endregion

#region Functions

function List-AvailableBoxes {
	Write-Host "`nAvailable boxes:"
	$boxBaseTemplateMappedToBoxVariableFiles | foreach { $_.Boxes } | foreach { Write-Host $_.BaseName }
}

function Write-Usgae {
	Write-Host "`nUsage: .\make.ps1 [box name] options"
	
	Write-Host "`n[box name] is one of the boxes variable file names (without extension) in the 'boxes' subdirectories`n"
	Write-Host "Options:`n"
	Write-Host "-Reconfigure: Prompt for the iso files caches again"
	Write-Host "-Logging: Log the packer command output to a file in .logs folder"
	Write-Host "-List: List all available boxes"
	Write-Host "-Validate: Call packer validate"
	Write-Host "-Inspect: Call packer inspect"
}

function Create-DirectoryIfNotExists([string]$path) {
	if(-Not (Test-Path $path)) {
		New-Item $path -ItemType Directory
	}
}

function Get-AbsoluteUri([string]$path) {
	if(-not [string]::IsNullOrEmpty($path)) { 
		return (New-Object -TypeName System.Uri -ArgumentList $path).AbsoluteUri
	}
}

function Get-ChefDependencies() {
	Push-Location -Path $selectedTemplateVsBoxes.ChefCookbooksFolder
	. berks vendor ..\..\.cookbooks_deps
	Pop-Location
}

function Log([string]$message) {
	if($Logging) {
		$dateTime = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
		Write-Host -ForegroundColor Blue "$dateTime $message" 
	}
}

#endregion

if($makeCommand -eq "clean") {
	Remove-Item "$windowsCookbooks\.kitchen" -Recurse -ErrorAction Ignore
	Remove-Item "$ubuntuCookbooksPath\.kitchen" -Recurse -ErrorAction Ignore
	Remove-Item ".\.output" -Recurse -ErrorAction Ignore
	Remove-Item ".\.boxes" -Recurse -ErrorAction Ignore
	Remove-Item "..\.cookbooks_deps" -Recurse -ErrorAction Ignore
	Remove-Item ".\.logs" -Recurse -ErrorAction Ignore

	if($IncludePackerCache){
		$boxBaseTemplateMappedToBoxVariableFiles | foreach { $_.Template } | foreach { 
			$templateFolder = (Get-Item $_).Directory
			$cacheFolder = Join-Path $templateFolder "packer_cache"
			Remove-Item $cacheFolder -Recurse -ErrorAction Ignore
		}
	}
	return
}

if($makeCommand -eq "list") {
	List-AvailableBoxes
	return
}

if([string]::IsNullOrEmpty($packerTemplateFile)) {
	Write-Host "`nInvalid box name."
	List-AvailableBoxes
	return
}

Create-DirectoryIfNotExists ".logs" >$null
Create-DirectoryIfNotExists ".config" >$null

if(-Not (Test-Path ".config\packer.cmd")) {
	$packerPath = Read-Host -Prompt "Enter packer executable full path"
	Add-Content -Path ".config\packer.cmd" -Value "@$packerPath %*";
}

if($reconfigure) {
	Remove-Item -Path ".config\machine-variables.json" -ErrorAction SilentlyContinue
}

if(-Not (Test-Path ".config\machine-variables.json")) {
	
	$localIsoDir = Read-Host -Prompt "Enter local iso cache directory path (optional, e.g C:\Users\Blah\VMImages)"
	$networkIsoDir = Get-AbsoluteUri (Read-Host -Prompt "Enter network iso cache directory path (optional, e.g \\qsnas1\shared\images)")

	$json = @{ iso_local_cache_dir = if($localIsoDir -eq $null) {""} else {$localIsoDir} ; iso_network_cache_dir = if($networkIsoDir -eq $null) {""} else {$networkIsoDir} }
	Add-Content -Path ".config\machine-variables.json" -Value (ConvertTo-Json $json);
}

$packerCmd = (Get-Item .\.config\packer.cmd).FullName
$machineVarPath = (Get-Item .\.config\machine-variables.json).FullName

if($Logging) {
	$env:PACKER_LOG=1
	$now = Get-Date
	Start-Transcript -Path ".\.logs\$($BoxName)_build_log-$($now.Month)-$($now.Day)-$($now.Hour)-$($now.Minute)-$($now.Second)-$($now.Millisecond).txt"
}

try {
	if($makeCommand -eq "build" -or $makeCommand -eq "validate") {
		Get-ChefDependencies
	}

	Push-Location -Path (Split-Path -Parent $packerTemplateFile)
	
	try {
		$packerArgs = @($makeCommand)

		if($makeCommand -eq "build" -or $makeCommand -eq "validate") {			
			$machineVarArg = "-var-file=""$machineVarPath"""
			$boxVarArg = "-var-file=""$boxVariablesFile"""
			$packerArgs = $packerArgs + @($machineVarArg,$boxVarArg)
		}

		$packerArgs = $packerArgs + $RemainingArguments + @($packerTemplateFile)
		Log "Executing: $packerCmd $packerArgs"
		. $packerCmd $packerArgs
	}
	finally {
		Pop-Location
	}
}
finally {
	if($Logging) { 	
		Stop-Transcript
		$env:PACKER_LOG=$null
	}
}