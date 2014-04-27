# LtdTemplate::Code::Call - Represents a method call in an LtdTemplate
#
# @author Brian Katzung (briank@kappacs.com), Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Call < LtdTemplate::Code

    # Initialize a method call object.
    #
    # @param template [LtdTemplate] The template object
    # @param target (Code for) the target to call
    # @param method [String] The method to invoke
    # @param parameters [LtdTemplate::Code::Parameters] Code blocks for
    #  the method parameters
    def initialize (template, target, method, parameters)
	super template
	@target, @method, @parameters = target, method, parameters
    end

    # Return the result of executing the call.
    #
    # @param opts [Hash] Option hash
    # @option opts [String] :method A method to call on the return value
    def evaluate (opts = {})
	# Evaluate the target code to get a method receiver
	receiver = rubyversed(@target).receiver

	# Increase the call count and call depth.
	@template.use :calls
	@template.use :call_depth

	result = rubyversed(receiver).evaluate({ :method => @method,
	  :parameters => rubyversed(@parameters).evaluate })

	# Decrease the call depth.
	@template.use :call_depth, -1

	result
    end

end

# END
