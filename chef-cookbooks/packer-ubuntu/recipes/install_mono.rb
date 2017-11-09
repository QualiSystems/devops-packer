apt_repository 'mono-official' do
   uri 'http://download.mono-project.com/repo/ubuntu'
   distribution 'xenial'
   components ['main']
   keyserver 'keyserver.ubuntu.com'
   key '3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF'
   action :add
end

package 'install latest mono' do
	package_name ['mono-complete']
end