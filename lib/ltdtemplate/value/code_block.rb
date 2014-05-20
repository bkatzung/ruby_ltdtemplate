# LtdTemplate::Value::Code_Block - Represents an explicit code block
#	in an LtdTemplate
#
# Code blocks are wrappers around code sequences. They are essentially
# anonymous functions; they accept optional parameters and create a new
# namespace for the duration of each execution.
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/value'

class LtdTemplate::Value::Code_Block

    include LtdTemplate::Value

    attr_reader :code

    def initialize (template, code)
	super template
	@code = code
    end

    # Evaluate supported methods on code blocks. Most methods
    # are passed to the code block.
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

    # In contrast to an implied code block, an uncalled explicit code
    # block generates no template output.
    def tpl_text; ''; end

end

# END
