# LtdTemplate::Value::Regexp - Represents a string and options that
#  might become a Regexp in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/value'

class LtdTemplate::Value::Regexp

    include LtdTemplate::Method_Handler

    def initialize (template, value)
	@template, @value = template, value
	@options = 0
    end

    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call'
	    if @template.limits[:regexp] != false then @value
	    else Regexp.new @value, @options
	    end
	when 'ci', 'ignorecase' then @options |= Regexp::IGNORECASE; self
	when 'class' then 'Regexp'
	when 'enabled' then @template.limits[:regexp] == false
	when 'ext', 'extended' then @options |= Regexp::EXTENDED; self
	when 'multi', 'multiline' then @options |= Regexp::MULTILINE; self
	when 'str', 'string' then Regexp.new(@value, @options).to_s
	when 'type' then 'regexp'
	when '!' then self # Not compiled
	else nil
	end
    end

    def receiver; self; end

    def tpl_text; ''; end

end

# END
