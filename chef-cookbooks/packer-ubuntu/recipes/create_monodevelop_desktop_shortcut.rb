box_settings = node['box_settings']
ssh_user = box_settings['ssh_user']
ssh_user_group = box_settings['ssh_user_group']

directory "/home/#{ssh_user}/Desktop" do
  owner ssh_user
  group ssh_user_group
  mode '0755'
end

template 'create monodevelop desktop shortcut' do
  source 'monodevelop.desktop.erb'
  path "/home/#{ssh_user}/Desktop/monodevelop.desktop"
  owner ssh_user
  group ssh_user_group
  mode '0775'
  variables({
	  'monodevelop_version': node['monodevelop_verison'],
  })
end