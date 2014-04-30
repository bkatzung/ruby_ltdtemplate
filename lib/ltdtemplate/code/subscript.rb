# LtdTemplate::Code::Subscript - Represents an array subscript in
#	an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'
require 'ltdtemplate/value/array_splat'

class LtdTemplate::Code::Subscript < LtdTemplate::Code

    def initialize (template, base, subscripts)
	super template
	@base, @subscripts = base, subscripts
    end

    #
    # Evaluate the target's value.
    #
    def evaluate (opts = {})
	case opts[:method]
	when '=', '?=' then do_set opts # Support array assignment
	else rubyversed(target(true)).evaluate opts
	end
    end

    #
    # Return subscripts calculated from the supplied code blocks.
    #
    def evaluate_subscripts (meter = false)
	subscripts = []
	@subscripts.each do |code|
	    subscript = rubyversed(code).evaluate
	    case subscript
	    when LtdTemplate::Value::Array_Splat
		subscripts.concat subscript.positional
	    when Numeric, String then subscripts << subscript
	    end
	end

	if meter
	    @template.using :subscript_depth, subscripts.size
	    @template.use :subscripts, subscripts.size
	end

	subscripts
    end

    # Subscripted variables are assignable, so defer evaluating
    # the receiver.
    def receiver; self; end

    #
    # Return the target value, variable[sub1, ..., subN]
    #
    def target (meter = false)
	subscripts = evaluate_subscripts meter
	if subscripts.empty? then rubyversed(@base).evaluate
	else rubyversed(@base).evaluate.in_rubyverse(@template)[*subscripts, {}]
	end
    end

    ##################################################

    # Implement = and ?=
    def do_set (opts)
	subscripts = evaluate_subscripts true
	if subscripts.empty?
	    # Treat expression[] as expression
	    rubyversed(@base).evaluate opts
	elsif opts[:method] != '?=' ||
	  rubyversed(@base).evaluate.in_rubyverse(@template)[*subscripts,
	  {}].nil?
	    # Assign if unconditional or unset
	    params = opts[:parameters]
	    params = params[0] if params.is_a? LtdTemplate::Univalue
	    rubyversed(@base).evaluate.in_rubyverse(@template)[*subscripts,
	      {}] = params
	end
	nil
    end

end

# END
