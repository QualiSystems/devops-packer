box_settings = node['box_settings']
ssh_user = box_settings['ssh_user']
ssh_user_group = box_settings['ssh_user_group']
monodevelop_directory = "/home/#{ssh_user}/monodevelop"
monodevelop_git_repo_dir = "#{monodevelop_directory}/6.1.2.44"
monodevelop_build_dir = "#{monodevelop_git_repo_dir}/main"

package 'install git' do
	package_name 'git'
end

package 'install monodevelop build dependencies' do
  package_name ['autoconf', 'automake', 'build-essential', 'cmake', 'gettext', 'libgdiplus', 'libglade2-dev', 'libgnomeui-dev', 'libgtk2.0-dev', 'libssh2-1-dev', 'libtool', 'libtool-bin', 'gtk-sharp2', 'libgnome2-dev', 'libgnomecanvas2-dev', 'gnome-sharp2']
end

directory monodevelop_directory do
  owner ssh_user
  group ssh_user_group
  mode '0775'
end

git 'clone monodevelop 6.1.2.44' do
  repository 'https://github.com/mono/monodevelop.git'
  revision 'monodevelop-6.1.2.44'
  depth 1
  destination monodevelop_git_repo_dir
  user ssh_user
  group ssh_user_group
  action :checkout
end

directory 'delete fsharp binding' do
  path "#{monodevelop_build_dir}/external/fsharpbinding"
  recursive true
  action :delete
end

cookbook_file 'remove fsharp from Makefile' do
  source 'Makefile.am'
  path "#{monodevelop_build_dir}/Makefile.am"
  action :create
end

cookbook_file 'remove fsharp from configuration file' do
  source 'configure.ac'
  path "#{monodevelop_build_dir}/configure.ac"
  action :create
end

execute 'configure monodevelop build' do
  user ssh_user
  cwd monodevelop_git_repo_dir
  live_stream true
  command './configure --prefix=/usr --profile=stable'
end

execute 'build monodevelop' do
  user ssh_user
  cwd monodevelop_git_repo_dir
  live_stream true
  ignore_failure true
  command 'make'
end