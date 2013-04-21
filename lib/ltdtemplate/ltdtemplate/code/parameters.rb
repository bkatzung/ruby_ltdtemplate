# LtdTemplate::Code::Parameters - Represents call parameters in an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Parameters < LtdTemplate::Code

    #
    # Create a parameter list builder with code to generate positional
    # values and possibly code to generate named values.
    #
    def initialize (template, positional = [], named = nil)
	super template

	# Save the code blocks for positional and named parameters.
	@positional, @named = positional, named
    end

    #
    # Evaluate the code provided for the positional and named parameters
    # and return a corresponding array t-value.
    #
    def get_value (opts = {})
	positional = @positional.map { |val| val.get_value }
	named = {}
	if @named
	    @named.each_slice(2) do |key, val|
		named[key.get_value.to_native] = val.get_value
	    end
	    scalar = false
	else
	    scalar = positional.size == 1
	end
	@template.factory(:array).set_value(positional, named, scalar)
    end

end
