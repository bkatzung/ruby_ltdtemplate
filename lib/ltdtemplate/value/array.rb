# LtdTemplate::Value::Array - Represents a combination array/hash value
#	in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'
require 'sarah'

class LtdTemplate::Value::Array < LtdTemplate::Code

    attr_reader :sarah

    def initialize (template)
	super template
	@sarah = Sarah.new
	@scalar = false
	@template.use :arrays
    end

    #
    # Access positional (sequential) or named (random-access)
    # parts of the array
    #
    def positional; @sarah.seq; end
    def named; @sarah.rnd; end

    #
    # Implement the subscripting interface. Note that the most recent
    # value is always used. (1 .. 0, 2, 0, 3)[0] is 3.
    # Items set within (or at the end of) the positional range at the
    # time will be positional. Otherwise, they will be named.
    #
    # Keys must be Ruby-native values; values must be template code
    # or values.
    #
    def has_item? (key); @sarah.has_key? key; end
    def get_item (key)
	@sarah.has_key?(key) ? @sarah[key] : @template.factory(:nil)
    end
    def set_item (key, value)
	@sarah[key] = value
	@template.using :array_size, @sarah.size
    end

    def to_boolean; true; end
    def to_native; @sarah.seq.map { |val| val.to_native }; end
    def to_text; @sarah.seq.map { |val| val.to_text }.join ''; end

    def get_value (opts = {})
	case opts[:method]
	when nil, 'call' then self
	when 'class' then @template.factory :string, 'Array'
	when 'join' then do_join opts
	when 'pop', '->' then do_pop opts
	when 'push', '+>' then do_push opts
	when 'rnd_size' then @template.factory :number, @sarah.rnd_size
	when 'seq_size' then @template.factory :number, @sarah.seq_size
	when 'shift', '<-' then do_shift opts
	when 'size' then @template.factory :number, @sarah.size
	when 'type' then @template.factory :string, 'array'
	when 'unshift', '<+' then do_unshift opts
	else do_method opts, 'Array'
	end
    end

    #
    # Scalar assignment is used instead of array assignment if the
    # parameter list contains exactly one positional parameter and
    # the ".." operator was not used.
    #
    def scalar?; @scalar and @sarah.seq_size == 1; end

    #
    # Clear all current positional and named values
    #
    def clear
	@sarah.clear
	@scalar = false
	self
    end

    #
    # Set positional and possibly named values. Keys must be ruby-native
    # values; values must be template code or values.
    #
    def set_value (positional, named = {}, scalar = false)
	clear
	@sarah.merge! positional, named
	@scalar = scalar
	self
    end

    #
    # Set (recursively) from a native array.
    #
    def set_from_array (data)
	clear
	data.each_index { |i| set_item i, map_native_value(data[i]) }
	self
    end

    #
    # Set (recursively) from a native hash.
    #
    def set_from_hash (data)
	clear
	data.each { |key, val| set_item key, map_native_value(val) }
	self
    end

    #
    # Combine array element values into a string
    #
    def do_join (opts)
	two = first = middle = last = ''
	if params = opts[:parameters]
	    params = params.positional
	    if params.size > 3
		two, first, middle, last =
		  params[0..3].map { |val| val.get_value.to_text }
	    elsif params.size > 0
		two = first = middle = last = params[0].get_value.to_text
	    end
	end

	text = @sarah.seq.map { |val| val.get_value.to_text }
	@template.factory :string, case text.size
	when 0 then ''
	when 1 then text[0]
	when 2 then "#{text[0]}#{two}#{text[1]}"
	else "#{text[0]}#{first}" + text[1..-2].join(middle) +
	  "#{last}#{text[-1]}"
	end
    end

    def do_pop (opts)
	@sarah.pop || @template.factory(:nil)
    end

    def do_push (opts)
	if params = opts[:parameters] then @sarah.append! params.sarah end
	@template.factory :nil
    end

    def do_shift (opts)
	@sarah.shift || @template.factory(:nil)
    end

    def do_unshift (opts)
	if params = opts[:parameters] then @sarah.insert! params.sarah end
	@template.factory :nil
    end

    protected

    def map_native_value (value)
	return @template.factory :number, value if value.is_a? Numeric
	return @template.factory :string, value if value.is_a? String
	return @template.factory(:array).set_from_array value if
	  value.is_a? Array
	return @template.factory(:array).set_from_hash value if
	  value.is_a? Hash
	@template.factory :nil
    end

end
