# LtdTemplate::Value::String - Represents a string in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Value::String < LtdTemplate::Code

    def initialize (template, value)
	super template
	template.use :string_total, value.length
	@value = value
    end

    def to_boolean; true; end
    def to_native; @value; end
    def to_text; @value; end

    def get_value (opts = {})
	case opts[:method]
	when nil, 'call', 'str', 'string' then self
	when 'class' then @template.factory :string, 'String'
	when 'flt', 'float' then @template.factory :number, @value.to_f
	when 'int' then @template.factory :number, @value.to_i
	when 'len', 'length' then @template.factory :number, @value.length
	when 'rng', 'range', 'slc', 'slice' then do_range_slice opts
	when 'type' then @template.factory :string, 'string'
	when '+' then do_add opts
	when '*' then do_multiply opts
	when 'idx', 'index', 'ridx', 'rindex' then do_index opts
	when '<', '<=', '==', '!=', '>=', '>' then do_compare opts
	else do_method opts, 'String'
	end
    end

    def do_add (opts)
	combined = @value
	if params = opts[:parameters]
	    params.positional.each do |tval|
		part = tval.to_text
		@template.using :string_length, (combined.length + part.length)
		combined += part
	    end
	end
	@template.factory :string, combined
    end

    def do_multiply (opts)
	str = ''
	params = params.positional if params = opts[:parameters]
	if params and params.size > 0
	    times = params[0].to_native
	    if times.is_a? Integer
		str = @value
		if times < 0
		    str = str.reverse
		    times = -times
		end
		@template.using :string_length, (str.length * times)
		str = str * times
	    end
	end
	@template.factory :string, str
    end

    # Implement string comparison operators
    def do_compare (opts)
	if params = opts[:parameters] and params.positional.size > 0
	    diff = params.positional[0].to_text
	else
	    diff = ''
	end

	diff = @value <=> diff
	@template.factory :boolean, case opts[:method]
	when '<' then diff < 0
	when '<=' then diff <= 0
	when '==' then diff == 0
	when '!=' then diff != 0
	when '>=' then diff >= 0
	when '>' then diff > 0
	end
    end

    # Index and rindex
    # str.index(substring[, offset])
    # str.rindex(substring[, offset]
    def do_index (opts)
	substr, offset = '', nil
	params = params.positional if params = opts[:parameters]
	substr = params[0].get_value.to_text if params and params.size > 0
	offset = params[1].get_value.to_native if params and params.size > 1
	case opts[:method][0]
	when 'r'
	    offset = -1 unless offset.is_a? Integer
	    @template.factory :number, (@value.rindex(substr, offset) || -1)
	else
	    offset = 0 unless offset.is_a? Integer
	    @template.factory :number, (@value.index(substr, offset) || -1)
	end
    end

    # Range and slice:
    # str.range([begin[, end]])
    # str.slice([begin[, length]])
    def do_range_slice (opts)
	op1, op2 = 0, -1
	params = params.positional if params = opts[:parameters]
	op1 = params[0].get_value.to_native if params and params.size > 0
	op2 = params[1].get_value.to_native if params and params.size > 1
	if opts[:method][0] == 'r' or op2 < 0
	    str = @value[op1..op2]
	else
	    str = @value[op1, op2]
	end
	@template.factory :string, (str || '')
    end

end
