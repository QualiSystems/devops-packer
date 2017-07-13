time_zone = node['box_settings']['time_zone']

template 'C:/Windows/Panther/Unattend/unattend.xml' do
  source 'SysprepUnattended.xml.erb'
  variables({
  	  'time_zone': !time_zone || time_zone.empty? ? 'UTC' : time_zone
  })
end