include_recipe 'chocolatey'

chocolatey_package 'vcredist-all' do
  action :install
end