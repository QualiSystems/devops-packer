Remove-Item ".\chef-cookbooks\packer-windows\.kitchen" -Recurse -ErrorAction Ignore
Remove-Item ".\.output" -Recurse -ErrorAction Ignore
Remove-Item ".\.boxes" -Recurse -ErrorAction Ignore
Remove-Item ".\.cookbooks_deps" -Recurse -ErrorAction Ignore
Remove-Item ".\.logs" -Recurse -ErrorAction Ignore
