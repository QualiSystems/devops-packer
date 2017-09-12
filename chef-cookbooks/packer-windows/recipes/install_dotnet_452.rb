include_recipe 'chocolatey'

chocolatey_package 'dotnet4.5.2' do
  action :install
end