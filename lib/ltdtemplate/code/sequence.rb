# LtdTemplate::Code::Sequence - Represents a code sequence (a list of
#	code steps) in an LtdTemplate
#
# Code sequences do not accept parameters or generate new namespaces.
# They are used for things like call parameters and subscript expressions.
# See also: LtdTemplate::Value::Code_Block.
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Sequence < LtdTemplate::Code

    def initialize (template, code)
	super template
	@code = code
    end

    # Evaluate the code sequence.
    def evaluate (opts = {})
	values = @code.map { |code| rubyversed(code).evaluate }
	case values.size
	when 0 then nil
	when 1 then values[0]
	else values.map { |val| rubyversed(val).tpl_text }.join ''
	end
    end

end

# END
