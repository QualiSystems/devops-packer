[CmdletBinding(DefaultParameterSetName="build")]
param(
	[switch]$IncludePackerCache
)

Remove-Item ".\chef-cookbooks\packer-windows\.kitchen" -Recurse -ErrorAction Ignore
Remove-Item ".\chef-cookbooks\packer-ubuntu\.kitchen" -Recurse -ErrorAction Ignore
Remove-Item ".\.output" -Recurse -ErrorAction Ignore
Remove-Item ".\.boxes" -Recurse -ErrorAction Ignore
Remove-Item ".\.cookbooks_deps" -Recurse -ErrorAction Ignore
Remove-Item ".\.logs" -Recurse -ErrorAction Ignore

if($IncludePackerCache){
	Remove-Item ".\windows\packer_cache" -Recurse -ErrorAction Ignore
	Remove-Item ".\linux\ubuntu\packer_cache" -Recurse -ErrorAction Ignore
}