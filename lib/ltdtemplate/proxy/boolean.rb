# LtdTemplate::Proxy::Boolean - Represents true/false in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'

class LtdTemplate::Proxy::Boolean < LtdTemplate::Proxy

    # Evaluate supported methods on boolean objects.
    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call' then @original
	when 'class' then 'Boolean'
	when 'str', 'string' then @original ? 'true' : 'false'
	when 'type' then 'boolean'
	when '+', '|', 'or' then do_or opts
	when '*', '&', 'and' then do_and opts
	when '!', 'not' then do_not opts
	else super opts
	end
    end

    # The template boolean value is the same as the original boolean value.
    def tpl_boolean; @original; end

    # Booleans have no textual value in templates.
    def tpl_text; ''; end

    ##################################################

    # Implement +/| (or):
    # bool|(bool1, ..., boolN)
    # True if ANY boolean is true. Evaluates {} blocks until true.
    def do_or (opts)
	if !@original && (params = opts[:parameters])
	    params.each(:seq) do |idx, expr|
		return true if rubyversed(expr).evaluate(:method => 'call').
		  in_rubyverse(@template).tpl_boolean
	    end
	end
	@original
    end

    # Implement */& (and):
    # bool&(bool1, ..., boolN)
    # True if ALL booleans are true. Evaluates {} blocks until false.
    def do_and (opts)
	if @original && (params = opts[:parameters])
	    params.each(:seq) do |idx, expr|
		return false unless rubyversed(expr).
		  evaluate(:method => 'call').in_rubyverse(@template).
		  tpl_boolean
	    end
	end
	@original
    end

    # Implement ! (not):
    # bool!(bool1, ..., boolN)
    # True if ALL booleans are false. Evaluates {} blocks until true.
    def do_not (opts)
	if !@original && (params = opts[:parameters])
	    params.each(:seq) do |idx, expr|
		return false if rubyversed(expr).
		  evaluate(:method => 'call').in_rubyverse(@template).
		  to_boolean
	    end
	end
	!@original
    end

end
