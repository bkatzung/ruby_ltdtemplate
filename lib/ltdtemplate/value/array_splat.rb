# For array/ or array% (similar to Ruby's *array)

require 'ltdtemplate'

module LtdTemplate::Value; end

class LtdTemplate::Value::Array_Splat

    include LtdTemplate::Method_Handler

    attr_reader :named, :positional

    def initialize (positional, named = nil)
	@positional, @named = positional, named
    end

    def evaluate (opts = {})
	case opts[:method]
	when 'type' then 'array_splat'
	else nil
	end
    end

    def receiver; self; end

    def tpl_text; ''; end

end

# END
