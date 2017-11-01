include Chef::Mixin::ShellOut

class Chef::Recipe::PackerRubyHelper
  def self.get_var_or_default(bag, variable_name, default_value = nil)
		node_value = bag[variable_name]
		value = !node_value || node_value.empty? ? default_value : node_value
		raise "no value was passed for box_settings.#{variable_name}" if !value
		return value
	end
  def self.execute_command(command)
        command_out = shell_out(command)
		return command_out.stdout
  end
  def self.get_packages_containing(package_name, except_for = nil)
		out = except_for ?
				self.execute_command("dpkg --list | awk '{ print $2 }' | grep #{package_name} | grep -v #{except_for}" ) :
				self.execute_command("dpkg --list | awk '{ print $2 }' | grep #{package_name}")
		return out.split("\n")
  end
end