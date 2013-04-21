# LtdTemplate::Code::Variable - Represents a variable in an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Variable < LtdTemplate::Code

    def initialize (template, name)
	super template
	case name[0]
	when '@', '^'
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

    #
    # Return the namespace item for this variable.
    #
    def target; namespace.get_item(@name); end

    #
    # Implement the subscripting interface.
    #
    def has_item? (key); target.has_item? key; end
    def get_item (key); target.get_item key; end
    def set_item (key, value); target.set_item key, value; end

    #
    # Try to set the value.
    #
    def set_value (value)
	namespace.set_item(@name, value)
    end

    #
    # Is this variable set?
    # Among other possible uses, this is needed for determining when to
    # auto-vivicate array subscripts.
    #
    def is_set?; namespace.has_item? @name; end

    def get_value (opts = {})
	case opts[:method]
	when '=' then do_set opts	# see LtdTemplate::Code
	when '=?'
	    if is_set? then @template.factory :nil
	    else do_set opts
	    end
	else target.get_value opts
	end
    end

end
