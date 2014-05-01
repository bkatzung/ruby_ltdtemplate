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
	    @template.use :array
	    @template.using :array_size, (splat.positional.size +
	      splat.named.size)
	    end
	when '%' 
	  return @template.factory(:array_splat, [],
	    self.positional).tap do |splat|
	    @template.use :array
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

    # Access named (random-access) parts of the data structure.
    def named
	case @original
	when Hash then @original
	when Sarah then @original.to_h :nsq
	else {}
	end
    end

    # Access positional (sequential) parts of the data structure.
    def positional
	case @original
	when ::Array then @original
	when Sarah then @original.values :seq
	else []
	end
    end

    # Reflect original respond_to? :push for XKeys.
    def respond_to? (method)
	case method
	when :push then @original.respond_to? :push
	else super method
	end
    end

    # The template text value is the concatenation of sequential text values.
    def tpl_text
	self.positional.map { |val| rubyversed(val).tpl_text }.join ''
    end

    # Return a new array (Sarah) for auto-vivification.
    def xkeys_new (*args); @template.factory :array; end

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
		two, first, middle, last = params.values(:seq)[0..3]
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
	    @template.use :string_total, str.size
	    @template.using :string_length, str.size
	end
    end

    # Pop a value off the right end of the array.
    def do_pop (opts)
	@original.respond_to?(:pop) ? @original.pop : nil
    end

    # Push values onto the right end of the array.
    def do_push (opts)
	if params = opts[:parameters]
	    case @original
	    when ::Array then @original.push *params.values(:seq)
	    when Sarah then @original.append! params
	    end.tap do |res|
		@template.using res.size if res.respond_to? :size
	    end
	end
	nil
    end

    # Shift a value off the left end of the array.
    def do_shift (opts)
	@original.respond_to?(:shift) ? @original.shift : nil
    end

    # Unshift values onto the left end of the array.
    def do_unshift (opts)
	if params = opts[:parameters]
	    case @original
	    when ::Array then @original.unshift *params.values(:seq)
	    when Sarah then @original.insert! params
	    end.tap do |res|
		@template.using res.size if res.respond_to? :size
	    end
	end
	nil
    end

end

# END
