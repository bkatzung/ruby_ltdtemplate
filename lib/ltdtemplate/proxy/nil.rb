# LtdTemplate::Proxy::Nil - Represents nil in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'

class LtdTemplate::Proxy::Nil < LtdTemplate::Proxy

    # Evaluate supported nil object methods.
    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call' then nil
	when 'class' then 'Nil'
	when 'type' then 'nil'
	else super opts
	end
    end

    # The template boolean value is false.
    def tpl_boolean; false; end

    # The template text for nil is the empty string.
    def tpl_text; ''; end

end
