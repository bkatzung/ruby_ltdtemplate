# LtdTemplate::Code::Block - Represents a code block (a list of
#	code steps) in an LtdTemplate
#
# Implied code blocks do not accept parameters or generate new namespaces.
# They are used for things like call parameters and subscript expressions.
# See also: LtdTemplate::Value::Code_Block.
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Block < LtdTemplate::Code

    def initialize (template, code)
	super template
	@code = code
    end

    def evaluate (opts = {})
	values = @code.map { |code| rubyversed(code).evaluate }.
	  flatten
	case values.size
	when 0 then nil
	when 1 then values[0]
	else values
	end
    end

end

# END
