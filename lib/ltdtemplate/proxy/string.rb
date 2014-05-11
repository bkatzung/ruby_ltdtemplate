# LtdTemplate::Proxy::String - Proxies a string in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'
require 'sarah'

class LtdTemplate::Proxy::String < LtdTemplate::Proxy

    # Evaluate supported methods for strings.
    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call', 'str', 'string' then @original
	when 'capcase' then meter @original.capitalize
	when 'class' then 'String'
	when 'downcase' then meter @original.downcase
	when 'flt', 'float' then @original.to_f
	when 'html'
	    require 'htmlentities'
	    meter(HTMLEntities.new(:html4).encode(@original, :basic,
	      :named, :decimal))
	when 'idx', 'index', 'ridx', 'rindex' then do_index opts
	when 'int' then @original.to_i
	when 'join' then do_join opts
	when 'len', 'length' then @original.length
	when 'match' then do_match opts
	when 'pcte'
	  meter(@original.gsub(/[^a-z0-9]/i) { |c| sprintf "%%%2x", c.ord })
	when 'regexp'
	    if @template.options[:regexp] then ::Regexp.new @original
	    else nil
	    end
	when 'rep', 'rep1', 'replace', 'replace1' then do_replace opts
	when 'rng', 'range', 'slc', 'slice' then do_range_slice opts
	when 'split' then do_split opts
	when 'type' then 'string'
	when 'upcase' then meter @original.upcase
	when '+' then do_add opts
	when '*' then do_multiply opts
	when '<', '<=', '==', '!=', '>=', '>' then do_compare opts
	else super opts
	end
    end

    # Meter string resource usage
    def meter (str)
	# RESOURCE string_total: Combined length of computed strings
	@template.use :string_total, str.size
	# RESOURCE string_length: Length of longest modified string
	@template.using :string_length, str.size
	str
    end

    def tpl_text; @original; end

    ##################################################

    # "Add" (concatenate) strings
    def do_add (opts)
	combined = @original
	if params = opts[:parameters]
	    params.each(:seq) do |key, val|
		val = rubyversed(val).tpl_text
		@template.using :string_length, (combined.length + val.length)
		combined += val
	    end
	end
	meter combined
    end

    # Match a regular expression
    def do_match (opts)
	if (params = opts[:parameters]) && params.size(:seq) > 0 &&
	  params[0].is_a?(::Regexp)
	    params[0].in_rubyverse(@template).evaluate :method => 'match',
	      :parameters => Sarah[ @original, *params[1..-1].values ]
	else nil
	end
    end

    # "Multiply" (repeat) strings
    def do_multiply (opts)
	str = ''
	if (params = opts[:parameters]) && params.size(:seq) > 0
	    times = params[0]
	    if times.is_a? Integer
		str = @original
		if times < 0
		    str = str.reverse
		    times = -times
		end
		@template.use :string_total, (str.length * times)
		@template.using :string_length, (str.length * times)
		str = str * times
	    end
	end
	meter str
    end

    # Implement string comparison operators
    def do_compare (opts)
	if (params = opts[:parameters]) && (params.size(:seq) > 0)
	    diff = rubyversed(params[0]).tpl_text
	else
	    diff = ''
	end

	diff = @original <=> diff
	case opts[:method]
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
	params = opts[:parameters]
	if params && params.size(:seq) > 0
	    substr = rubyversed(params[0]).tpl_text
	end
	offset = params[1] if params && params.size(:seq) > 1
	case opts[:method][0]
	when 'r'
	    offset = -1 unless offset.is_a? Integer
	    @original.rindex(substr, offset) || -1
	else
	    offset = 0 unless offset.is_a? Integer
	    @original.index(substr, offset) || -1
	end
    end

    # String join
    # str.join(list)
    def do_join (opts)
	params = opts[:parameters]
    	if params && params.size(:seq) > 0
	    meter(params.values(:seq).map { |val| rubyversed(val).tpl_text }.
	      join(@original))
	else ''
	end
    end

    # Range and slice:
    # str.range([begin[, end]])
    # str.slice([begin[, length]])
    def do_range_slice (opts)
	op1, op2 = 0, -1
	params = opts[:parameters]
	op1 = params[0] if params && params.size(:seq) > 0
	op2 = params[1] if params && params.size(:seq) > 1
	if opts[:method][0] == 'r' || op2 < 0
	    str = @original[op1..op2]
	else str = @original[op1, op2]
	end
	meter(str || '')
    end

    # Replace and replace one
    # str.replace(pattern, replacement)
    # str.replace1(pattern, replacement)
    def do_replace (opts)
	if (params = opts[:parameters]) && params.size(:seq) > 1
	    pat, repl = params[0..1]
	    if opts[:method][-1] == '1'
		# replace one
		meter @original.sub(pat, repl)
	    else
		# replace all
		meter @original.gsub(pat, repl)
	    end
	else @original
	end
    end

    # Split
    # str.split(pattern[, limit])
    def do_split (opts)
	if opts[:parameters]
	    params = opts[:parameters][0..1].values
	else params = []
	end
	@original.split(*params).tap { |ary| ary.each { |str| meter str } }
    end

end

# END
