# LtdTemplate::Code::Parameters - Represents call parameters in an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'
require 'ltdtemplate/value/array_splat'

module LtdTemplate::Univalue; end

class LtdTemplate::Code::Parameters < LtdTemplate::Code

    attr_reader :positional, :named

    # Create a parameter list builder with code to generate positional
    # values and possibly code to generate named values.
    def initialize (template, positional = [], named = nil)
	super template

	# Save the code blocks for positional and named parameters.
	@positional, @named = positional, named
    end

    # Evaluate the code provided for the positional and named parameters
    # and return a corresponding Sarah.
    #
    # @return [Sarah]
    def evaluate (opts = {})
	params = @template.factory :array

	# Process the positional parameters (pos1, ..., posN)
	@positional.each do |code|
	    value = rubyversed(code).evaluate
	    if value.is_a? LtdTemplate::Value::Array_Splat
		# Merge parameters from array/ or array%
		# RESOURCE array_growth: Increases in array sizes
		@template.use :array_growth, value.positional.size
		params.concat value.positional
		if value.named
		    @template.use :array_growth, value.named.size / 2
		    params.set_pairs *value.named
		end
	    else params.push value
	    end
	end

	# Process the named parameters (.. key1, val1, ..., keyN, valN)
	if @named
	    @named.each_slice(2) do |k_code, v_code|
		params[rubyversed(k_code).evaluate] =
		  rubyversed(v_code).evaluate if v_code
	    end
	end

	# Is this a candidate for scalar assignment?
	params.extend LtdTemplate::Univalue if
	  !@named && params.size(:seq) == 1

	params
    end

end

# END
