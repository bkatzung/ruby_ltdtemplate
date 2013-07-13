# LtdTemplate - Ltd (limited) Template
#
# A template system with limitable resource usage.
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

class LtdTemplate

    TOKEN_MAP = {
	?. => :dot,		# method separator
	'..' => :dotdot,	# begin named values
	?( => :lparen,		# begin call parameters
	?, => :comma,		# next call parameter
	?) => :rparen,		# end call parameters
	?[ => :lbrack,		# begin array subscripts
	?] => :rbrack,		# end array subscripts
	?{ => :lbrace,		# begin code block
	?} => :rbrace		# end code block
    }

    # @!attribute [r] exceeded
    # @return [Symbol, nil]
    # The resource whose limit was being exceeded when an
    # LtdTemplate::ResourceLimitExceeded exception was raised.
    attr_reader :exceeded

    # @!attribute [r] factory_singletons
    # @return [Hash]
    # A hash of factory singletons (e.g. nil, true, and false values)
    # for this template.
    attr_reader :factory_singletons

    # @!attribute [r] limits
    # @return [Hash]
    # A hash of resource limits to enforce during parsing and rendering.
    attr_reader :limits

    # @!attribute [r] namespace
    # @return [LtdTemplate::Value::Namespace, nil]
    # The current namespace (at the bottom of the rendering namespace stack).
    attr_reader :namespace

    # @!attribute [r] options
    # @return [Hash]
    # Instance initialization options
    attr_reader :options

    # @!attribute [r] usage
    # @return [Hash]
    # A hash of resource usage. It is updated after calls to #parse and
    # #render.
    attr_reader :usage

    # @!attribute [r] used
    # @return [Hash]
    # A hash of used resources for this template
    attr_reader :used

    # @@classes contains the default factory classes. These can be overridden
    # globally using the #set_classes class method or per-template using the
    # #set_classes instance method.
    @@classes = {
	#
	# These represent storable values. Some may also occur as
	# literals in code blocks.
	#
	:array => 'LtdTemplate::Value::Array',
	:boolean => 'LtdTemplate::Value::Boolean',
	:explicit_block => 'LtdTemplate::Value::Code_Block',
	:namespace => 'LtdTemplate::Value::Namespace',
	:nil => 'LtdTemplate::Value::Nil',
	:number => 'LtdTemplate::Value::Number',
	:string => 'LtdTemplate::Value::String',

	#
	# These only occur as part of code blocks.
	#
	:call => 'LtdTemplate::Code::Call',
	:implied_block => 'LtdTemplate::Code::Code_Block',
	:parameters => 'LtdTemplate::Code::Parameters',
	:subscript => 'LtdTemplate::Code::Subscript',
	:variable => 'LtdTemplate::Code::Variable',
    }

    # Change default factory classes globally
    #
    # @param classes [Hash] A hash of factory symbols and corresponding
    #   classes to be instantiated.
    # @return [Hash] Returns the current class mapping.
    def self.set_classes (classes)
	@@classes.merge! classes
    end

    def initialize (options = {})
	@classes = @@classes
	@code = nil
	@factory_singletons = {}
	@limits = {}
	@namespace = nil
	@options = options
	@usage = {}
	@used = {}
    end

    # Parse a template from a string.
    #
    # @param template [String] A template string. Templates look
    #   like <tt>'literal<<template code>>literal...'</tt>.
    # @return [LtdTemplate]
    def parse (template)
	@usage = {}
	tokens = []
	literal = true
	trim_next = false

	# Template "text<<code>>text<<code>>..." =>
	# (text, code, text, code, ...)
	template.split(/<<(?!<)((?:[^<>]|<[^<]|>[^>])*)>>/s).each do |part|
	    if part.length > 0
		if literal
		    part.sub!(/^\s+/s, '') if trim_next
		    tokens.push [ :ext_string, part ]
		else
		    if part[0] == '.'
			tokens[-1][1].sub!(/\s+$/s, '') if
			  tokens[0] and tokens[-1][0] == :ext_string
			part = part[1..-1] if part.length > 1
		    end
		    part = part[0..-2] if trim_next = (part[-1] == '.')
		    tokens += get_tokens part
		end
	    else
		trim_next = false
	    end
	    literal = !literal
	end

	@code = parse_template tokens
	self
    end

    # Change default factory classes for this template.
    #
    # @param classes [Hash] A hash of factory symbols and corresponding
    #   classes to be instantiated.
    # @return [LtdTemplate]
    def set_classes (classes)
	@classes.merge! classes
	self
    end

    # Generate new code/value objects.
    #
    # @param type [Symbol] The symbol for the type of object to generate,
    #   e.g. :number, :string, :implicit_block, etc.
    # @param args [Array] Type-specific initialization parameters.
    # @return Returns the new code/value object.
    def factory (type, *args)
	use :factory
	type = @classes[type]
	file = type.downcase.gsub '::', '/'
	require file
	eval(type).instance(self, *args)
    end

    # Render the template.
    #
    # The options hash may include :parameters, which may be an array or
    # hash. These values will form the parameter array "_" in the root
    # namespace.
    #
    # @param options [Hash] Rendering options.
    # @return [String] The result of rendering the template.
    def render (options = {})
	@exceeded = nil		# No limit exceeded yet
	@namespace = nil	# Reset the namespace stack between runs
	@usage = {}		# Reset resource usage
	@used = {}		# No libraries used yet

	#
	# Accept template parameters from an array or hash.
	#
	parameters = factory :array
	parameters.set_from_array options[:parameters] if
	  options[:parameters].is_a? Array
	parameters.set_from_hash options[:parameters] if
	  options[:parameters].is_a? Hash

	#
	# Create the root namespace and evaluate the template code.
	#
	push_namespace 'render', parameters
	@code ? @code.get_value.to_text : ''
    end

    # Push a new namespace onto the namespace stack.
    #
    # @param method [String] The (native) method string. This will be
    #   available as <tt>$.method</tt> within the template.
    # @param parameters [Array<LtdTemplate::Code>] These are code blocks
    #   to set the namespace parameters (available as the "_" array in the
    #   template).
    # @param opts [Hash] Options hash.
    # @option opts [LtdTemplate::Value] :target The target of the method
    #   call. This will be available as <tt>$.target</tt> within the template.
    def push_namespace (method, parameters = nil, opts = {})
	use :namespaces
	use :namespace_depth
	@namespace = factory :namespace, method, parameters, @namespace
	@namespace.target = opts[:target] if opts[:target]
    end

    # Pop the current namespace from the stack.
    def pop_namespace
	if @namespace.parent
	    @namespace = @namespace.parent
	    use :namespace_depth, -1
	end
    end

    # Track incremental usage of a resource.
    #
    # @param resource [Symbol] The resource being used.
    # @param amount [Integer] The additional amount of the resource being
    #   used (or released, if negative).
    def use (resource, amount = 1)
	@usage[resource] ||= 0
	@usage[resource] += amount
	check_limit resource
    end

    # Track peak usage of a resource.
    #
    # @param resource [Symbol] The resource being used.
    # @param amount [Integer] The total amount of the resource currently
    #   being used.
    def using (resource, amount)
	@usage[resource] ||= 0
	@usage[resource] = amount if amount > @usage[resource]
	check_limit resource
    end

    # Throw an exception if a resource limit has been exceeded.
    #
    # @param resource [Symbol] The resource limit to be checked.
    def check_limit (resource)
	if @limits[resource] and @usage[resource] and
	  @usage[resource] > @limits[resource]
	    @exceeded = resource
	    raise LtdTemplate::ResourceLimitExceeded
	end
    end

    # Convert a string into an array of parsing tokens.
    #
    # @param str [String] The string to split into parsing tokens.
    # @return [Array<Array>]
    def get_tokens (str)
	tokens = []
	str.split(%r{(
	  /\*.*?\*/		# /* comment */
	  |
	  '(?:\\.|[^\.,\[\](){}\s])+# 'string
	  |
	  "(?:\\"|[^"])*"	# "string"
	  |
	  [@^][a-zA-Z0-9_]+	# root or parent identifier
	  |
	  [a-zA-Z_][a-zA-Z0-9_]*# alphanumeric identifier
	  |
	  -?\d+(?:\.\d+)?	# integer or real numeric literal
	  |
	  \.\.			# begin keyed values
	  |
	  [\.(,)\[\]{}]		# methods, calls, elements, blocks
	  |
	  \s+
	  )}mx).grep(/\S/).each do |token|
	    if token =~ %r{^/\*.*\*/$}s
		# Ignore comment
	    elsif token =~ /^'(.*)/s or token =~ /^"(.*)"$/s
		# String literal
		#tokens.push [ :string, $1.gsub(/\\(.)/, '\1') ]
		tokens.push [ :string, parse_strlit($1) ]
	    elsif token =~ /^-?\d+(?:\.\d+)?/
		# Numeric literal
		tokens.push [ :number, token ]
	    elsif TOKEN_MAP[token]
		# Delimiter
		tokens.push [ TOKEN_MAP[token] ]
	    elsif token =~ /^[@^][a-z0-9_]|^[a-z_]|^\$$/i
		# Variable or alphanumeric method name
		tokens.push [ :name, token ]
	    else
		# Punctuated method name
		tokens.push [ :method, token ]
	    end
	end

	tokens
    end

    # This is the top-level token parser.
    #
    # @param tokens [Array<Array>] The tokens to be parsed.
    # @return [LtdTemplate::Code] The implementation code.
    def parse_template (tokens); parse_block tokens; end

    # Parse a code block, stopping at any stop token.
    #
    # @param tokens [Array<Array>] The raw token stream.
    # @param stops [Array<Symbol>] An optional list of stop tokens, such
    #   as :comma (comma) or :rparen (right parenthesis).
    # @return [LtdTemplate::Code]
    def parse_block (tokens, stops = [])
	code = []
	while tokens[0]
	    break if stops.include? tokens[0][0]

	    token = tokens.shift# Consume the current token
	    case token[0]
	    when :string, :ext_string	# string literal
		code.push factory(:string, token[1])
	    when :number	# numeric literal
		code.push factory(:number, token[1])
	    when :name		# variable
		code.push factory(:variable, token[1])
	    when :lbrack	# variable element subscripts
		subs = parse_subscripts tokens
		code.push factory(:subscript, code.pop, subs) if code[0]
	    when :dot		# method call w/ or w/out parameters
		case tokens[0][0]
		when :name, :method, :string
		    method = tokens.shift
		    if tokens[0] and tokens[0][0] == :lparen
			tokens.shift	# Consume (
			params = parse_parameters tokens
		    else
			params = factory :parameters
		    end
		    code.push factory(:call, code.pop, method[1], params) if
		      code[0]
		end if tokens[0]
	    when :method	# punctuated method call
		# Insert the implied dot and re-parse
		tokens.unshift [ :dot ], token
	    when :lparen	# call
		params = parse_parameters tokens
		code.push factory(:call, code.pop, 'call', params) if code[0]
	    when :lbrace	# explicit code block
		code.push factory(:explicit_block,
		  parse_block(tokens, [ :rbrace ]))
		tokens.shift if tokens[0]	# Consume }
	    end
	end

	(code.size == 1) ? code[0] : factory(:implied_block, code)
    end

    # Parse subscripts after the opening left bracket
    #
    # @param tokens [Array<Array>]] The token stream.
    # @return [Array<LtdTemplate::Code>]
    def parse_subscripts (tokens)
	subs = parse_list tokens, [ :rbrack ], [ :lbrack ]
	tokens.shift		# Consume ]
	subs
    end

    # Parse a positional and/or named parameter list
    #
    # @param tokens [Array<Array>] The token stream.
    # @return [LtdTemplate::Code::Parameters]
    def parse_parameters (tokens)
	positional = parse_list tokens, [ :dotdot, :rparen ]

	if tokens[0] and tokens[0][0] == :dotdot
	    tokens.shift	# Consume ..
	    named = parse_list tokens, [ :rparen ]
	else
	    named = nil
	end

	tokens.shift		# Consume )
	factory :parameters, positional, named
    end

    # Common code for parsing various lists.
    #
    # @param tokens [Array<Array>] The remaining unparsed tokens.
    # @param stops [Array<Symbol>] The list of tokens that stop parsing
    #   of the list.
    # @param resume [Array<Symbol>] The list of tokens that will resume
    #   parsing if they occur after a stop token (e.g. subscript parsing
    #   stops at ']' but resumes if followed by '[').
    # @return [Array<LtdTemplate::Code>]
    def parse_list (tokens, stops, resume = [])
	list = []
	block_stops = stops + [ :comma ]
	while tokens[0]
	    if !stops.include? tokens[0][0]
		block = parse_block tokens, block_stops
		list.push block if block
		tokens.shift if tokens[0] and tokens[0][0] == :comma
	    elsif tokens[1] and resume.include? tokens[1][0]
		tokens.shift 2	# Consume stop and resume tokens
	    else
		break
	    end
	end

	list
    end

    # Parse escape sequences in string literals.
    #
    #  These are the same as in Ruby double-quoted strings:
    #  \M-\C-x    meta-control-x
    #  \M-x       meta-x
    #  \C-x, \cx  control-x
    #  \udddd     Unicode four-digit, 16-bit hexadecimal code point dddd
    #  \xdd       two-digit, 8-bit hexadecimal dd
    #  \ddd       one-, two-, or three-digit, 8-bit octal ddd
    #  \c         any other character c is just itself
    #
    # @param raw [String] The original (raw) string.
    # @return [String] The string after escape processing.
    def parse_strlit (raw)
	raw.split(%r{(\\M-\\C-.|\\M-.|\\C-.|\\c.|
	  \\u[0-9a-fA-F]{4}|\\x[0-9a-fA-f]{2}|\\[0-7]{1,3}|\\.)}x).
	  map do |part|
	    case part
	    when /\\M-\\C-(.)/ then ($1.ord & 31 | 128).chr
	    when /\\M-(.)/ then ($1.ord | 128).chr
	    when /\\C-(.)/, /\\c(.)/ then ($1.ord & 31).chr
	    when /\\u(.*)/ then $1.to_i(16).chr(Encoding::UTF_16BE)
	    when /\\x(..)/ then $1.to_i(16).chr
	    when /\\([0-7]+)/ then $1.to_i(8).chr
	    when /\\(.)/ then "\a\b\e\f\n\r\s\t\v"["abefnrstv".
	      index($1) || 9] || $1
	    else part
	    end
	  end.join ''
    end

end

# This exception is raised when a resource limit is exceeded.
class LtdTemplate::ResourceLimitExceeded < RuntimeError; end
