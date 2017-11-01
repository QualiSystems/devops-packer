execute 'delete docs' do
  command 'sudo rm -rf /usr/share/doc/*'
end

execute 'delete caches' do
  command 'sudo find /var/cache -type f -exec rm -rf {} \;'
end

execute 'delete logs' do
  command 'sudo find /var/log/ -name *.log -exec rm -f {} \;'
end