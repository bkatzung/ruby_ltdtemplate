# LtdTemplate::Proxy::Regexp - Proxy for Regexp objects in an LtdTemplates
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/proxy'

class LtdTemplate::Proxy::Regexp < LtdTemplate::Proxy

    # Evaluate supported methods on Regexp (regular expression) objects.
    def evaluate (opts = {})
	# These methods are supported regardless of whether regexp
	# is enabled.
	case opts[:method]
	when nil, 'call'
	    if @template.options[:regexp] then return @original
	    else return nil
	    end
	when 'class' then return 'Regexp'
	when 'str', 'string'
	    return @original.to_s.tap do |str|
		# RESOURCE string_total: Combined length of computed strings
		@template.use :string_total, str.size
		# RESOURCE string_length: Length of longest modified string
		@template.using :string_length, str.size
	    end
	when 'type' then return 'regexp'
	end

	# These methods are disabled unless regexp is enabled.
	if @template.options[:regexp]
	    case opts[:method]
	    when 'ci', 'ignorecase'
		if (@original.options & ::Regexp::IGNORECASE) != 0
		    return @original
		else return ::Regexp.new(@original.source,
		  @original.options | ::Regexp::IGNORECASE)
		end
	    when 'ext', 'extended'
		if (@original.options & ::Regexp::EXTENDED) != 0
		    return @original
		else return ::Regexp.new(@original.source,
		  @original.options | ::Regexp::EXTENDED)
		end
	    when 'match' then return do_match opts
	    when 'multi', 'multiline'
		if (@original.options & ::Regexp::MULTILINE) != 0
		    return @original
		else return ::Regexp.new(@original.source,
		  @original.options | ::Regexp::MULTILINE)
		end
	    end
	end

	super opts
    end

    def tpl_text; ''; end

    ##################################################

    def do_match (opts)
	if (params = opts[:parameters]) && params.size(:seq) > 0 &&
	  params[0].is_a?(::String)
	    # Track array size generated??
	    @original.match(*params[0..1].values)
	else nil
	end
    end

end

# END
