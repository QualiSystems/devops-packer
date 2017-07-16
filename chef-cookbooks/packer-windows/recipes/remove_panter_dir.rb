directory 'Remove old panther directory' do
  path 'C:\Windows\Panther'
  recursive true
  action :delete
end