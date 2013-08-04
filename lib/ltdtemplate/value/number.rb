# LtdTemplate::Value::Number - Represents a number in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Value::Number < LtdTemplate::Code

    def initialize (template, value = 0)
	super template
	case value
	when Numeric then @value = value
	when String then @value = (value =~ /\./) ? value.to_f : value.to_i
	end
    end

    def to_boolean; true; end
    def to_native; @value; end
    def to_text; @value.to_s; end

    def get_value (opts = {})
	case opts[:method]
	when nil, 'call' then self
	when 'abs' then (@value >= 0) ? self :
	  @template.factory(:number, -@value)
	when 'ceil' then @template.factory :number, @value.ceil
	when 'class' then @template.factory :string, 'Number'
	when 'floor' then @template.factory :number, @value.floor
	when 'flt', 'float' then @template.factory :number, @value.to_f
	when 'int' then @template.factory :number, @value.to_i
	when 'str', 'string' then @template.factory :number, @value.to_s
	when 'type' then @template.factory :string, 'number'
	when '+' then do_sequential(opts) { |a, b| a + b }
	when '-' then do_subtract opts
	when '*' then do_sequential(opts) { |a, b| a * b }
	when '/' then do_sequential(opts) { |a, b| a / b }
	when '%' then do_sequential(opts) { |a, b| a % b }
	when '&' then do_sequential(opts) { |a, b| a & b }
	when '|' then do_sequential(opts) { |a, b| a | b }
	when '^' then do_sequential(opts) { |a, b| a ^ b }
	when '<', '<=', '==', '!=', '>=', '>' then do_compare opts
	else do_method opts, 'Number'
	end
    end

    # Type (for :missing_method callback)
    def type; :number; end

    # Implement sequential operations (+, *, /, %, &, |, ^)
    def do_sequential (opts = {}, &block)
	if params = opts[:parameters]
	    @template.factory(:number,
	      params.positional.map { |tval| tval.to_native }.
	      select { |nval| nval.is_a? Numeric }.
	      inject(@value, &block))
	else
	    @value
	end
    end

    # Implement "-" method (subtraction/negation)
    def do_subtract (opts)
	sum = @value
	params = params.positional if params = opts[:parameters]
	if !params or params.size == 0
	    sum = -sum
	else
	    params.each do |tval|
		nval = tval.to_native
		sum -= nval if nval.is_a? Numeric
	    end
	end
	@template.factory :number, sum
    end

    # Implement numeric comparison operators
    def do_compare (opts)
	diff = 0
	if params = opts[:parameters] and params.positional.size > 0
	    diff = params.positional[0].to_native
	    diff = 0 unless diff.is_a? Numeric
	end
	diff = @value - diff
	@template.factory :boolean, case opts[:method]
	when '<' then diff < 0
	when '<=' then diff <= 0
	when '==' then diff == 0
	when '!=' then diff != 0
	when '>=' then diff >= 0
	when '>' then diff > 0
	end
    end

end
