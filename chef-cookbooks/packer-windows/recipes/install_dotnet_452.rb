include_recipe 'chocolatey'

chocolatey_package 'dotnet4.5.2' do
  action :install
  returns [0, 3010]
end