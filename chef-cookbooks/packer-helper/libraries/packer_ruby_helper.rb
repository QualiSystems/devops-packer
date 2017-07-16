class Chef::Recipe::PackerRubyHelper
  def self.get_var_or_default(bag, variable_name, default_value = nil)
		node_value = bag[variable_name]
		value = !node_value || node_value.empty? ? default_value : node_value
		raise "no value was passed for box_settings.#{variable_name}" if !value
		return value
	end
end