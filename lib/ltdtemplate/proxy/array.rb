# LtdTemplate::Proxy::Array - Proxy for arrays, hashes, and Sarahs
#	in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'sarah'
require 'xkeys'
require 'ltdtemplate/proxy'
require 'ltdtemplate/value/array_splat'

class LtdTemplate::Proxy::Array < LtdTemplate::Proxy

    # Proxy methods to access the underlying data structure.
    # These must be #include'd before XKeys::Hash for proper
    # method resolution.
    Module.new do
	def [] (*args); @original.[] *args; end
	def []= (*args); @original.[]= *args; end
	def fetch (*args); @original.fetch *args; end
	def push (*args); @original.push *args; end
    end.tap { |mod| include mod }
    include XKeys::Hash

    # Evaluate supported array methods.
    def evaluate (opts = {})
	# Methods supported for all proxied types.
	case opts[:method]
	when nil, 'call' then return @original
	when 'class' then return 'Array'
	when 'each', 'each_rnd', 'each_seq' then return do_each opts
	when 'rnd_size' then return self.named.size
	when 'seq_size' then return self.positional.size
	when 'size' then return @original.size
	when 'type' then return 'array'
	when '/' 
	  return @template.factory(:array_splat, self.positional,
	    self.named.to_a.flatten(1)).tap do |splat|
	    size = splat.positional.size + splat.named.size
	    # RESOURCE array_growth: Increases in array sizes
	    @template.use :array_growth, size
	    # RESOURCE array_size: Size of largest modified array
	    @template.using :array_size, size
	    end
	when '%' 
	  return @template.factory(:array_splat, [],
	    self.positional).tap do |splat|
	    @template.use :array_growth, splat.named.size
	    @template.using :array_size, splat.named.size
	    end
	end

	# Methods supported by Array and Sarah objects.
	case @original
	when ::Array, Sarah
	    case opts[:method]
	    when 'join' then return do_join opts
	    when 'pop', '->' then return do_pop opts
	    when 'push', '+>' then return do_push opts
	    when 'shift', '<-' then return do_shift opts
	    when 'unshift', '<+' then return do_unshift opts
	    end
	end

	super opts
    end

    # Meter usage when modifying the array.
    #
    # @param node [Array,Hash,Sarah] The array being updated.
    # @param key [Object] The index/key being added/updated.
    def meter (node, key)
	case node
	when ::Array
	    if key == :[] then growth = 1	# (push)
	    elsif key > node.size then growth = key - node.size
	    else growth = 0			# existing index
	    end
	when Hash, Sarah
	    growth = node.has_key?(key) ? 0 : 1
	end
	@template.use :array_growth, growth if growth > 0
	@template.using :array_size, node.size + growth
    end

    # Access named (random-access) parts of the data structure.
    def named
	case @original
	when Hash then @original
	when Sarah
	    # RESOURCE array: Total number of arrays created
	    @template.use :array
	    size = @original.size :nsq
	    @template.use :array_growth, size
	    @template.using :array_size, size
	    @original.to_h :nsq
	else {}
	end
    end

    # Access positional (sequential) parts of the data structure.
    def positional
	case @original
	when ::Array then @original
	when Sarah
	    @template.use :array
	    size = @original.size :seq
	    @template.use :array_growth, size
	    @template.using :array_size, size
	    @original.values :seq
	else []
	end
    end

    # Reflect original respond_to? :push, etc. for XKeys.
    def respond_to? (method)
	case method
	when :[], :[]=, :fetch, :push then @original.respond_to? method
	else super method
	end
    end

    # The template text value is the concatenation of sequential text values.
    def tpl_text
	self.positional.map { |val| rubyversed(val).tpl_text }.join ''
    end

    # Return a new array (Sarah) for auto-vivification.
    def xkeys_new (k2, info, opts)
	meter info[:node], info[:key1]
	@template.factory :array
    end

    # Check array growth on final assignment
    def xkeys_on_final (node, key, value)
	meter node, key
    end

    ############################################################

    # Loop over each key, value
    def do_each (opts)
	results = @template.factory :array
	if params = opts[:parameters] and params.size(:seq) > 0
	    body = params[0]
	    if opts[:method] != 'each_rnd'
		(seq = self.positional).each_index do |idx|
		    @template.use :iterations
		    each_params = @template.factory(:array).
		      push idx, self[idx]
		    results.push body.evaluate(:method => 'each_seq',
		      :parameters => each_params)
		    @template.using :array_size, results.size
		end
	    end
	    if opts[:method] != 'each_seq'
		(rnd = self.named).each do |key, val|
		    @template.use :iterations
		    each_params = @template.factory(:array).
		      push key, val
		    results.push body.evaluate(:method => 'each_rnd',
		      :parameters => each_params)
		    @template.using :array_size, results.size
		end
	    end
	end
	results
    end

    # Combine sequential array element values into a string
    def do_join (opts)
	two = first = middle = last = ''
	if params = opts[:parameters]
	    if params.size(:seq) > 3
		two, first, middle, last = params[0..3].values
	    elsif params.size(:seq) > 0
		two = first = middle = last = params[0]
	    end
	end

	text = self.positional.map { |val| rubyversed(val).tpl_text }
	case text.size
	when 0 then ''
	when 1 then text[0]
	when 2 then "#{text[0]}#{two}#{text[1]}"
	else "#{text[0]}#{first}" + text[1..-2].join(middle) +
	  "#{last}#{text[-1]}"
	end.tap do |str|
	    # RESOURCE string_total: Combined length of computed strings
	    @template.use :string_total, str.size
	    # RESOURCE string_length: Length of longest modified string
	    @template.using :string_length, str.size
	end
    end

    # Pop a value off the right end of the array.
    def do_pop (opts)
	if @original.respond_to? :pop
	    @template.use :array_growth, -1
	    @original.pop
	else nil
	end
    end

    # Push values onto the right end of the array.
    def do_push (opts)
	if params = opts[:parameters]
	    case @original
	    when ::Array
		@template.use :array_growth, params.size(:seq)
		@original.push *params.values(:seq)
	    when Sarah
		# Assume worst-case growth, then "push"
		@template.use :array_growth, params.size
		adjust = @original.size + params.size
		@original.append! params

		# Adjust actual growth if needed
		adjust = @original.size - adjust
		@template.use :array_growth, adjust if adjust < 0
	    end
	    @template.using :array_size, @original.size
	end
	nil
    end

    # Shift a value off the left end of the array.
    def do_shift (opts)
	if @original.respond_to? :shift
	    @template.use :array_growth, -1
	    @original.shift
	else nil
	end
    end

    # Unshift values onto the left end of the array.
    def do_unshift (opts)
	if params = opts[:parameters]
	    case @original
	    when ::Array
		@template.use :array_growth, params.size(:seq)
		@original.unshift *params.values(:seq)
	    when Sarah
		@template.use :array_growth, params.size
		adjust = @original.size + params.size
		@original.insert! params
		adjust = @original.size - adjust
		@template.use :array_growth, adjust if adjust < 0
	    end
	    @template.using :array_size, @original.size
	end
	nil
    end

end

# END
