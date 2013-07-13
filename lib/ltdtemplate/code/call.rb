# LtdTemplate::Code::Call - Represents a method call in an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Call < LtdTemplate::Code

    # Initialize a method call object.
    #
    # @param template [LtdTemplate] The template object
    # @param target [LtdTemplate::Code] The target object
    # @param method [String] The method to call
    # @param parameters [LtdTemplate::Code::Parameters] The call parameters
    def initialize (template, target, method, parameters)
	super template
	@target, @method, @parameters = target, method, parameters
    end

    # Return the result of executing the call.
    #
    # @param opts [Hash] Option hash
    # @option opts [String] :method A method to call on the return value
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

    # Pass has/get/set_item calls through to result of call;
    # in some cases it might be the same value each time.
    def has_item? (key); get_value.has_item? key; end
    def get_item (key); get_value.get_item key; end
    def set_item (key, value); get_value.set_item key, value; end

end
