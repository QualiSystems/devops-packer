time_zone = node['box_settings']['time_zone']

script 'set time zone' do
  interpreter "bash"
  code <<-EOH
    sudo timedatectl set-timezone #{time_zone}
    EOH
end