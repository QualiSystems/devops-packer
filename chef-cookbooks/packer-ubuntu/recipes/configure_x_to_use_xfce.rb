box_settings = node['box_settings']
ssh_user = box_settings['ssh_user']
ssh_group = box_settings['ssh_user_group']

file 'configure x server to start xfce with startx' do
  content 'xfce4-session'
  owner ssh_user
  group ssh_group
  mode '0644'
  path "/home/vagrant/.xsession"
  action :create
end