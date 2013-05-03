# LtdTemplate::Code::Call - Represents a method call in an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Call < LtdTemplate::Code

    #
    # Initialize a method call object.
    #
    # template:: the template object.
    # target:: the target object.
    # method:: a native string indicating the method to call.
    # parameters:: e.g. LtdTemplate::Code::Parameters, encapsulating the
    #   code blocks to generate the call parameters.
    def initialize (template, target, method, parameters)
	super template
	@target, @method, @parameters = target, method, parameters
    end

    def get_value (opts = {})
	# Increase the call count and call depth.
	@template.use :calls
	@template.use :call_depth

	result = @target.get_value({ :method => @method,
	  :parameters => @parameters.get_value })

	# Decrease the call depth.
	@template.use :call_depth, -1

	opts[:method] ? result.get_value(opts) : result
    end

end
