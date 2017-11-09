execute 'apt-get autoremove' do
  command 'sudo apt-get -y autoremove'
end

execute 'apt-get clean' do
  command 'sudo apt-get -y clean'
end