package 'install xfce desktop environment' do
	package_name ['xfce4', 'xserver-xorg-legacy']
end

file 'prevent audio app from starting on desktop session startup' do
  path "/etc/xdg/autostart/pulseaudio.desktop"
  action :delete
end

file 'prevent screen saver from starting on desktop session startup' do
  path "/etc/xdg/autostart/xscreensaver.desktop"
  action :delete
end