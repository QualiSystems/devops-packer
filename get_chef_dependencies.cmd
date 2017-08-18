@echo off
cd chef-cookbooks\packer-windows
berks vendor ..\..\.cookbooks_deps
cd ..\..