include_recipe 'chocolatey'

chocolatey_package 'dotnet4.6.2' do
  action :install
end