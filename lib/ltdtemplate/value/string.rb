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
	when 'capcase' then @template.factory :string, @value.capitalize
	when 'class' then @template.factory :string, 'String'
	when 'downcase' then @template.factory :string, @value.downcase
	when 'flt', 'float' then @template.factory :number, @value.to_f
	when 'html'
	    require 'htmlentities'
	    @template.factory :string, HTMLEntities.new(:html4).
	      encode(@value, :basic, :named, :decimal)
	when 'idx', 'index', 'ridx', 'rindex' then do_index opts
	when 'int' then @template.factory :number, @value.to_i
	when 'join' then do_join opts
	when 'len', 'length' then @template.factory :number, @value.length
	when 'pcte' then @template.factory(:string,
	  @value.gsub(/[^a-z0-9]/i) { |c| sprintf "%%%2x", c.ord })
	when 'regexp' then do_regexp opts
	when 'rep', 'rep1', 'replace', 'replace1' then do_replace opts
	when 'rng', 'range', 'slc', 'slice' then do_range_slice opts
	when 'split' then do_split opts
	when 'type' then @template.factory :string, 'string'
	when 'upcase' then @template.factory :string, @value.upcase
	when '+' then do_add opts
	when '*' then do_multiply opts
	when '<', '<=', '==', '!=', '>=', '>' then do_compare opts
	else do_method opts, 'String'
	end
    end

    # Type (for :missing_method callback)
    def type; :string; end

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

    # String join
    # str.join(list)
    def do_join (opts)
	params = params.positional if params = opts[:parameters]
    	if params and params.size > 0
	    @template.factory(:string, params.map do |val|
	      val.get_value.to_text end.join(@value))
	else
	    @template.factory :string, ''
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

    # Convert to regexp string
    def do_regexp (opts)
	(@template.limits[:regexp] != false) ? self :
	(LtdTemplate::Value::Regexp.new @template, @value)
    end

    # Replace and replace one
    # str.replace(pattern, replacement)
    # str.replace1(pattern, replacement)
    def do_replace (opts)
	params = params.positional if params = opts[:parameters]
	if params.size > 1
	    pat = params[0].get_value
	    pat = pat.respond_to?(:to_regexp) ? pat.to_regexp : pat.to_native
	    repl = params[1].get_value.to_native
	    if opts[:method][-1] == '1'
		# replace one
		@template.factory :string, @value.sub(pat, repl)
	    else
		# replace all
		@template.factory :string, @value.gsub(pat, repl)
	    end
	else
	    self
	end
    end

    # Split
    # str.split(pattern[, limit])
    def do_split (opts)
	split_opts = []
	params = params.positional if params = opts[:parameters]
	if params.size > 0
	    pattern = params[0].get_value
	    split_opts << ((pattern.respond_to? :to_regexp) ?
	      pattern.to_regexp : pattern.to_native)
	    split_opts << params[1].get_value.to_native if params.size > 1
	end
	@template.factory(:array).set_from_array @value.split(*split_opts)
    end

end

class LtdTemplate::Value::Regexp < LtdTemplate::Value::String

    def initialize (template, value)
	super template, value
	@options = 0
    end

    def to_regexp
	@regexp ||= Regexp.new @value, @options
    end

    def get_value (opts = {})
	case opts[:method]
	when 'ci', 'ignorecase' then @options |= Regexp::IGNORECASE; self
	when 'ext', 'extended' then @options |= Regexp::EXTENDED; self
	when 'multi', 'multiline' then @options |= Regexp::MULTILINE; self
	when 'type' then @template.factory :string, 'regexp'
	else super
	end
    end

end

# END
