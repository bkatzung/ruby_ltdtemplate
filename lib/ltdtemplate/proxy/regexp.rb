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
	when nil, 'call'
	    if @template.options[:regexp] then @original
	    else evaluate :method => 'string'
	    end
	when 'ci', 'ignorecase'
	    if @original.options & Regexp::IGNORECASE then @original
	    else Regexp.new @original.source,
	      @original.options | Regexp::IGNORECASE
	    end
	when 'class' then 'Regexp'
	when 'enabled' then @template.options[:regexp] == true
	when 'ext', 'extended'
	    if @original.options & Regexp::EXTENDED then @original
	    else Regexp.new @original.source,
	      @original.options | Regexp::EXTENDED
	    end
	when 'multi', 'multiline'
	    if @original.options & Regexp::MULTILINE then @original
	    else Regexp.new @original.source,
	      @original.options | Regexp::MULTILINE
	    end
	when 'str', 'string'
	    @original.to_s.tap do |str|
		@template.use :string_total, str.size
		@template.using :string_length, str.size
	    end
	when 'type' then 'regexp'
	else super opts
	end
    end

    def tpl_text; ''; end

end

# END
