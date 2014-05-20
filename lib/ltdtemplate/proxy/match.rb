# LtdTemplate::Proxy::Match - Proxies a regexp match in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'

class LtdTemplate::Proxy::Match < LtdTemplate::Proxy

    # Access array-like results
    def [] (*args); @original[*args]; end

    # Evaluate supported methods for regexp matches.
    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call' then @original
	when 'begin', 'end', 'offset' then do_offset opts
	when 'class' then 'Match'
	when 'length', 'size' then @original.size
	when 'type' then 'match'
	end
    end

    # Renders as empty string in a template.
    def tpl_text; ''; end

    ##################################################

    def do_offset (opts)
	if (params = opts[:parameters]) && params.size(:seq) > 0 &&
	  params[0].is_a?(::Numeric)
	    @original.send opts[:method].to_sym, params[0]
	else nil
	end
    end

end

# END
