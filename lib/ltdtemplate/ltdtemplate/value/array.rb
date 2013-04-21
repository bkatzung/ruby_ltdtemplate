# LtdTemplate::Value::Array - Represents a combination array/hash value
#	in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Value::Array < LtdTemplate::Code

    attr_reader :named, :positional

    def initialize (template)
	super template
	@positional = []# positional values (val1, ..., valN)
	@named = {}	# named values (.. key1, kval1, ..., keyN, kvalN)
	@scalar = false
	@template.use :arrays
    end

    #
    # Implement the subscripting interface. Note that the most recent
    # value is always used. (1 .. 0, 2, 0, 3)[0] is 3.
    # Items set within (or at the end of) the positional range at the
    # time will be positional. Otherwise, they will be named.
    #
    # Keys must be Ruby-native values; values must be template code
    # or values.
    #
    def has_item? (key)
	@named.has_key? key or
	  (key.is_a?(Integer) and key >= 0 and key < @positional.size)
    end
    def get_item (key)
	return @named[key] if @named.has_key? key
	return @positional[key] if key.is_a? Integer and
	  key >= 0 and key < @positional.size
	@template.factory :nil
    end
    def set_item (key, value)
	if key.is_a? Integer and key >= 0 and key <= @positional.size
	    @positional[key] = value
	    @named.delete key
	    psize = @positional.size
	    while @named.has_key? psize
		@positional[psize] = @named.delete psize
		psize += 1
	    end
	else
	    @named[key] = value
	end
	@template.using :array_size, @positional.size + @named.size
    end

    def to_boolean; true; end
    def to_native; @positional.map { |val| val.to_native }; end
    def to_text; @positional.map { |val| val.to_text }.join ''; end

    def get_value (opts = {})
	case opts[:method]
	when nil, 'call' then self
	when 'add' then do_add opts
	when 'join' then do_join opts
	when 'num_pos' then @template.factory :number, @positional.size
	when 'num_opts' then @template.factory :number, @named.size
	when 'size' then @template.factory :nunber,
	  (@positional.size + @named.size)
	when 'type' then @template.factory :string, 'array'
	else @template.factory :nil
	end
    end

    #
    # Scalar assignment is used instead of array assignment if the
    # parameter list contains exactly one positional parameter and
    # the ".." operator was not used.
    #
    def scalar?; @scalar and @positional.size == 1; end

    #
    # Clear all current positional and named values
    #
    def clear
	@scalar = false
	@positional.clear
	@named.clear
	self
    end

    #
    # Set positional and possibly named values. Keys must be ruby-native
    # values; values must be template code or values.
    #
    def set_value (positional, named = {}, scalar = false)
	clear
	@scalar = scalar
	@positional.concat positional
	named.each { |key, val| set_item key, val }
	@scalar = true if scalar
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
    # Add new items with nil or specific values
    #
    def do_add (opts)
	params = opts[:parameters]
	if params.positional.size
	    tnil = @template.factory :nil
	    params.positional.each { |item| set_item(item.to_native, tnil) }
	end
	if params.named.size
	    params.named.each { |item, val| set_item(item, val) }
	end
	@template.factory :nil
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

	text = @positional.map { |val| val.get_value.to_text }
	@template.factory :string, case text.size
	when 0 then ''
	when 1 then text[0]
	when 2 then "#{text[0]}#{two}#{text[1]}"
	else "#{text[0]}#{first}" + text[1..-2].join(middle) +
	  "#{last}#{text[-1]}"
	end
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
