# LtdTemplate::Code::Subscript - Represents an array subscript in
#	an LtdTemplate
#
# Author:: Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# Copyright:: 2013 Brian Katzung and Kappa Computer Solutions, LLC
# License:: MIT License

require 'ltdtemplate/code'

class LtdTemplate::Code::Subscript < LtdTemplate::Code

    def initialize (template, base, subscripts)
	super template
	@base, @subscripts = base, subscripts
    end

    #
    # Return native subscripts calculated from the supplied code blocks.
    #
    def native_subs (usage = false)
	nsubs = @subscripts ?
	  @subscripts.map { |sub| sub.get_value.to_native }.flatten : []
	num_subs = nsubs.size
	if usage and num_subs > 0
	    @template.using :subscript_depth, num_subs
	    @template.use :subscripts, num_subs
	end
	nsubs
    end

    #
    # Return the target value, variable[sub1, ..., subN]
    #
    def target (usage = false)
	current = @base.get_value
	native_subs(usage).each { |subs| current = current.get_item subs }
	current
    end

    #
    # Implement the subscript interface for the target.
    #
    def has_item? (key); target.has_item? key; end
    def get_item (key); target.get_item key; end
    def set_item (key, value); target(true).set_item key, value; end

    #
    # Set the target's value.
    #
    def set_value (value)
	subs = native_subs true
	if subs.size == 0
	    # If there are no subscripts, just use the base.
	    @base.set_value value
	else
	    #
	    # Traverse all but the last subscript, trying to autovivicate
	    # new arrays as we go. This will silently fail if there is an
	    # existing non-array value somewhere.
	    #
	    current = @base
	    current.set_value @template.factory :array unless current.is_set?
	    subs[0..-2].each do |sub|
		if !current.has_item? sub
		    current.set_item sub, @template.factory(:array)
		end
		current = current.get_item sub
	    end
	    current.set_item subs[-1], value
	end
	self
    end

    def get_value (opts = {})
	case opts[:method]
	when '=' then do_set opts	# see LtdTemplate::Code
	else target.get_value opts
	end
    end

end
