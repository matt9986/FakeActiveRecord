require_relative './new_attr_accessor.rb'
class MassObject < Accessibles
  def self.set_attrs(*attributes)
  	new_attr_accessor(*attributes)
  	self.instance_variable_set("@attributes", attributes)
  end

  def self.attributes
  	instance_variable_get("@attributes")
  end

  def self.parse_all(results)
  end

  def initialize(params = {})
  	params.each do |key, value|
  		if self.class.attributes.include?(key.to_sym)
	  		self.send("#{key}=".to_sym, value)
	  	else
	  		raise "mass assignment to unregistered attribute #{key}"
	  	end
  	end
  end
end
