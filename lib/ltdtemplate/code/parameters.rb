# LtdTemplate::Code::Parameters - Represents call parameters in an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Parameters < LtdTemplate::Code

    attr_reader :positional, :named

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
	named = {}

	# Process the positional parameters (pos1, ..., posN)
	positional = @positional.map do |code|
	    val = code.get_value
	    if val.is_a? LtdTemplate::Code::Parameters
		if val.named.is_a? Hash
		    # Named parameters from array/
		    val.named.each { |key, val| named[key] = val }
		elsif val.named.is_a? Array
		    # Named parameters from array%
		    val.named.each_slice(2) do |key, val|
			named[key.get_value.to_native] = val if val
		    end
		end
		val.positional # Positional parameters from array/
	    else val
	    end
	end.flatten

	# Process the named parameters (.. key1, val1, ..., keyN, valN)
	if @named
	    if @named.is_a? Hash then named.merge! @named
	    else
		@named.each_slice(2) do |key, val|
		    named[key.get_value.to_native] = val.get_value if val
		end
	    end
	    scalar = false
	else
	    scalar = (positional.size == 1) && named.empty?
	end

	array = @template.factory(:array).set_value(positional, named, scalar)

	# Parameters may get called if chained, e.g. array/.type
	opts[:method] ? array.get_value(opts) : array
    end

end
