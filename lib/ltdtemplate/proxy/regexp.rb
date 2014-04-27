# LtdTemplate::Proxy::Regexp - Proxy for Regexp objects in an LtdTemplates
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'

class LtdTemplate::Proxy::Regexp < LtdTemplate::Proxy

    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call' then @original
	when 'class' then 'Regexp'
	when 'enabled' then @template.limits[:regexp] == false
	when 'type' then 'regexp'
	else nil
	end
    end

    def tpl_text; ''; end

end

# END
