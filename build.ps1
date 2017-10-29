[CmdletBinding(DefaultParameterSetName="build")]
param
(

	[parameter(Position=0, ParameterSetName="build", Mandatory=$true, HelpMessage="One of the box variable json file names (without extension) in the boxes subdirectories`nYou can also run .\build.ps1 -List to see all available boxes")]
	[parameter(Position=0, ParameterSetName="validate", Mandatory=$true, HelpMessage="One of the box variable json file names (without extension) in the boxes subdirectories`nYou can also run .\build.ps1 -List to see all available boxes")]
	[parameter(Position=0, ParameterSetName="inspect", Mandatory=$true, HelpMessage="One of the box variable json file names (without extension) in the boxes subdirectories`nYou can also run .\build.ps1 -List to see all available boxes")]
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
	[string]$Remaining
)

#region Script variables

$windowsBaseTemplate = (Get-Item ".\windows\windows_base_template.json").FullName
$ubuntuBaseTemplate = (Get-Item ".\linux\ubuntu\ubuntu.json").FullName

$boxBaseTemplateMappedToBoxVariableFiles = 
@(
	@{ Template = $windowsBaseTemplate ; Boxes = Get-ChildItem -Path ".\windows\boxes"},
	@{ Template = $ubuntuBaseTemplate ; Boxes = Get-ChildItem -Path ".\linux\ubuntu\boxes"};
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
	Write-Host "`nUsage: .\build.ps1 [box name] options"
	
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

#endregion

$packerCommand = $PsCmdlet.ParameterSetName

if($packerCommand -eq "list") {
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
	
	$localIsoDir = Get-AbsoluteUri (Read-Host -Prompt "Enter local iso cache directory path (optional, e.g C:\Users\Blah\VMImages)")
	$networkIsoDir = Get-AbsoluteUri (Read-Host -Prompt "Enter network iso cache directory path (optional, e.g \\qsnas1\shared\images)")

	$json = @{ iso_local_cache_dir = if($localIsoDir -eq $null) {""} else {$localIsoDir} ; iso_network_cache_dir = if($networkIsoDir -eq $null) {""} else {$networkIsoDir} }
	Add-Content -Path ".config\machine-variables.json" -Value (ConvertTo-Json $json);
}

$packerCmd = (Get-Item .\.config\packer.cmd).FullName
$machineVarPath = (Get-Item .\.config\machine-variables.json).FullName

if($Logging) {
	$now = Get-Date
	Start-Transcript -Path ".\.logs\$($BoxName)_build_log-$($now.Month)-$($now.Day)-$($now.Hour)-$($now.Minute)-$($now.Second)-$($now.Millisecond).txt"
}

if($packerCommand -eq "build") {
	. .\get_chef_dependencies.cmd
}

Push-Location -Path (Split-Path -Parent $packerTemplateFile)

if($packerCommand -eq "build" -or $packerCommand -eq "validate") {
	. $packerCmd $packerCommand -var-file="""$machineVarPath""" -var-file="""$boxVariablesFile""" $Remaining $packerTemplateFile
}
else {
	. $packerCmd $packerCommand $Remaining $packerTemplateFile	
}

Pop-Location

if($Logging) { Stop-Transcript }