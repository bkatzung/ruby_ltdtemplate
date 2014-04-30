# LtdTemplate::Proxy::Regexp - Proxy for Regexp objects in an LtdTemplates
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'

class LtdTemplate::Proxy::Regexp < LtdTemplate::Proxy

    # Evaluate supported methods on Regexp (regular expression) objects.
    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call' then @original
	when 'class' then 'Regexp'
	when 'enabled' then @template.limits[:regexp] == false
	when 'str', 'string'
	    @original.to_s.tap do |str|
		@template.use :string_total, str.size
		@template.using :string_length, str.size
	    end
	when 'type' then 'regexp'
	else nil
	end
    end

    def tpl_text; ''; end

end

# END
