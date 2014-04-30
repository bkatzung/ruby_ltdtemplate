# For array/ or array% (similar to Ruby's *array)

require 'ltdtemplate'

module LtdTemplate::Value; end

class LtdTemplate::Value::Array_Splat

    include LtdTemplate::Method_Handler

    attr_reader :named, :positional

    # @param positional [Array] Positional parameters
    # @param named [Array] Flat array of key, value pairs
    def initialize (positional, named = nil)
	@positional, @named = positional, named
    end

    # Evaluate support array splat methods. Very little is supported,
    # as these are only intended to be used in parameter and subscript
    # list expansions.
    def evaluate (opts = {})
	case opts[:method]
	when 'type' then 'array_splat'
	else nil
	end
    end

    def receiver; self; end

    # Unlike arrays, these generate no template text.
    def tpl_text; ''; end

end

# END
