linux_headers_pkgs = PackerRubyHelper.get_packages_containing("'linux-headers'")
package linux_headers_pkgs do
  action :purge  
end

redundant_linux_kernels = PackerRubyHelper.get_packages_containing("'linux-image-.*-generic'", "`uname -r`")
package redundant_linux_kernels do
  action :purge
end

linux_source = PackerRubyHelper.get_packages_containing("'linux-source'")
package linux_source do
  action :purge
end

doc_packages = PackerRubyHelper.get_packages_containing("'-doc$'")
package doc_packages do
  action :purge
end

obsolete_networking = ['ppp', 'pppconfig', 'pppoeconf']
package obsolete_networking do
  action :purge
end

redundant_packages = ['popularity-contest', 'installation-report', 'command-not-found', 'command-not-found-data', 'friendly-recovery', 'bash-completion', 'fonts-ubuntu-font-family-console', 'laptop-detect']
package redundant_packages do
  action :purge
end

package 'linux-firmware' do
  action :purge
end

is_desktop = node['box_settings']['is_desktop']
if !is_desktop || is_desktop.downcase == "false"
	x11_packages = ['libx11-data', 'xauth', 'libxmuu1', 'libxcb1', 'libx11-6', 'libxext6']
	package x11_packages do
	  action :purge
	end
end

execute 'apt-get autoremove' do
  command 'sudo apt-get -y autoremove'
end

execute 'apt-get clean' do
  command 'sudo apt-get -y clean'
end