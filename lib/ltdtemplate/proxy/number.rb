# LtdTemplate::Proxy::Number - Proxy for a number in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'

class LtdTemplate::Proxy::Number < LtdTemplate::Proxy

    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call' then @original
	when 'abs', 'ceil', 'floor'
	    @original.send opts[:method].to_sym
	when 'class' then 'Number'
	when 'flt', 'float' then @original.to_f
	when 'int' then @original.to_i
	when 'str', 'string' then @original.to_s
	when 'type' then 'number'
	when '+' then do_sequential(opts) { |a, b| a + b }
	when '-' then do_subtract opts
	when '*' then do_sequential(opts) { |a, b| a * b }
	when '/' then do_sequential(opts) { |a, b| a / b }
	when '%' then do_sequential(opts) { |a, b| a % b }
	when '&' then do_sequential(opts) { |a, b| a & b }
	when '|' then do_sequential(opts) { |a, b| a | b }
	when '^' then do_sequential(opts) { |a, b| a ^ b }
	when '<', '<=', '==', '!=', '>=', '>' then do_compare opts
	else super opts
	end
    end

    def tpl_text; @original.to_s; end

    ##################################################

    # Implement numeric comparison operators
    def do_compare (opts)
	diff = 0
	if (params = opts[:parameters]) && (params.size(:seq) > 0)
	    diff = params[0]
	    diff = 0 unless diff.is_a? Numeric
	end
	diff = @original - diff
	case opts[:method]
	when '<' then diff < 0
	when '<=' then diff <= 0
	when '==' then diff == 0
	when '!=' then diff != 0
	when '>=' then diff >= 0
	when '>' then diff > 0
	end
    end

    # Implement sequential operations (+, *, /, %, &, |, ^)
    def do_sequential (opts = {}, &block)
	if params = opts[:parameters]
	    params.values(:seq).select { |val| val.is_a? Numeric }.
	      inject(@original, &block)
	else @original
	end
    end

    # Implement "-" method (subtraction/negation)
    def do_subtract (opts)
	sum = @original
	params = opts[:parameters]
	if !params || params.size(:seq) == 0 then -@original
	else do_sequential(opts) { |a, b| a - b }
	end
    end

end

# END
