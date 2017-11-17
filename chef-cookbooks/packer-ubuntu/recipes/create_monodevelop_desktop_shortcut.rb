box_settings = node['box_settings']
ssh_user = box_settings['ssh_user']
ssh_user_group = box_settings['ssh_user_group']
home_folder = "/home/#{ssh_user}"
monodevelop_version = node['monodevelop_version']

cookbook_file 'create a script that executes monodevelop' do
  source 'monodevelop.sh'
  path "#{home_folder}/monodevelop/#{monodevelop_version}/monodevelop.sh"
  mode '0775'
  action :create
end

directory "#{home_folder}/Desktop" do
  owner ssh_user
  group ssh_user_group
  mode '0755'
end

template 'create monodevelop desktop shortcut' do
  source 'monodevelop.desktop.erb'
  path "#{home_folder}/Desktop/monodevelop.desktop"
  owner ssh_user
  group ssh_user_group
  mode '0775'
  variables({
	  'monodevelop_version': monodevelop_version,
  })
end