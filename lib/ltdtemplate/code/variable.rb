# LtdTemplate::Code::Variable - Represents a variable in an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Variable < LtdTemplate::Code

    def initialize (template, name)
	super template
	if name.size > 1 && (name[0] == '@' || name[0] == '^')
	    # @var is in the root namespace
	    # ^var is in the parent namespace
	    @modifier = name[0]
	    @name = name[1..-1]
	    @name = @name.to_i if @name =~ /^(?:0|[1-9]\d*)$/
	else
	    # Standard bottom-to-top namespace search variable
	    @modifier = nil
	    @name = name
	end
    end

    #
    # Evaluate
    #
    def evaluate (opts = {})
	case opts[:method]
	when '=', '?='
	    if opts[:method] != '?=' || self.namespace[@name].nil?
		params = opts[:parameters]
		params = params[0] if params.is_a? LtdTemplate::Univalue
		self.namespace[@name] = params
	    end
	    nil
	else rubyversed(self.namespace[@name]).evaluate opts
	end
    end

    #
    # Return the namespace in which this variable currently resides
    # (or would reside, if it doesn't currently exist).
    #
    def namespace
	case @modifier
	when '@' then base = @template.namespace.root
	when '^' then base = @template.namespace.parent || @template.namespace
	else base = @template.namespace
	end
	base.find_item(@name) || base
    end

end

# END
