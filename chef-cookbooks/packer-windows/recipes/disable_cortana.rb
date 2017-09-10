registry_key 'HKLM\Software\Policies\Microsoft\Windows\Windows Search' do
  values [{
    :name => 'AllowCortana',
    :type => :dword,
    :data => 0
  }]
end