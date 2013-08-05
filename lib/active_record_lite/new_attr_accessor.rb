class Accessibles
	def self.new_attr_accessor(*splat)
		splat.each do |symbol|
			self.send(:define_method, symbol.to_s) do
				instance_variable_get("@"+symbol.to_s)
			end

			self.send(:define_method, symbol.to_s + "=") do |value|
				instance_variable_set("@"+symbol.to_s, value)
			end
		end
	end
end