# LtdTemplate::Code::Code_Block - Represents a code block (a list of
#	code steps) in an LtdTemplate
#
# Implied code blocks do not accept parameters or generate new namespaces.
# They are used for things like call parameters and subscript expressions.
# See also: LtdTemplate::Value::Code_Block.
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Code_Block < LtdTemplate::Code

    def initialize (template, code)
	super template
	@code = code
    end

    def get_value (opts = {})
	values = @code.map { |part| part.get_value }.flatten
	case values.size
	when 0 then @template.nil
	when 1 then values[0]
	else @template.factory(:array).set_value(values)
	end
    end

end
