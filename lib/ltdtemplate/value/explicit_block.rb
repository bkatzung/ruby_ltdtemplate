# LtdTemplate::Value::Explicit_Block - Represents an explicit code block
#	in an LtdTemplate
#
# Explicit code blocks are wrappers around implied code blocks. They are
# essentially anonymous functions; they accept optional parameters and
# create a new namespace for the duration of each execution.
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/value'

class LtdTemplate::Value::Explicit_Block

    include LtdTemplate::Value

    attr_reader :code

    def initialize (template, code)
	super template
	@code = code
    end

    def evaluate (opts = {})
	case opts[:method]
	when nil then self
	when 'class' then 'Code'
	when 'type' then 'code'
	else
	    @template.push_namespace opts[:method], opts[:parameters],
	      :target => (opts[:target] || self)
	    result = rubyversed(@code).evaluate
	    @template.pop_namespace
	    result
	end
    end

    def tpl_text; ''; end

end

# END
