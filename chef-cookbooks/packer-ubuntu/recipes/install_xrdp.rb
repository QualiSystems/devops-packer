box_settings = node['box_settings']

package 'install xrdp' do
	package_name ['xrdp']
end

cookbook_file 'configure X server wrapper to allow anybody to strat it' do
  source 'Xwrapper.config'
  path '/etc/X11/Xwrapper.config'
  action :create
end

template 'configure xrdp with user credentials' do
  source 'xrdp.ini.erb'
  path '/etc/xrdp/xrdp.ini'
  variables({
	  'username': box_settings['ssh_user'],
	  'user_password': box_settings['ssh_user_password']
  })
end