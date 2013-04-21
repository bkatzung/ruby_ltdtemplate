# LtdTemplate::Value::Code_Block - Represents an explicit code block in an
#	LtdTemplate
#
# Explicit code blocks are wrappers around implied code blocks. They are
# essentially anonymous functions; they accept optional parameters and
# create a new namespace for the duration of each execution.
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Value::Code_Block < LtdTemplate::Code

    attr_reader :code

    def initialize (template, code)
	super template
	@code = code
    end

    def to_boolean; true; end
    def to_native; self; end
    def to_text; ''; end

    def get_value (opts = {})
	case opts[:method]
	when nil then self
	when 'type' then @template.factory :string, 'code'
	else
	    @template.push_namespace opts[:method], opts[:parameters],
	      :target => (opts[:target] || self)
	    result = @code.get_value
	    @template.pop_namespace
	    result
	end
    end

end
