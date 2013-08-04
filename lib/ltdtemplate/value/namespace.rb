# LtdTemplate::Value::Namespace - Represents an LtdTemplate variable namespace
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/value/array'

class LtdTemplate::Value::Namespace < LtdTemplate::Value::Array

    attr_reader :method, :parameters, :parent, :root
    attr_accessor :target

    def initialize (template, method, parameters, parent = nil)
	super template
	@method, @parameters = method, parameters
	@root = parent ? parent.root : self
	@parent = parent
	@target = nil
	clear
    end

    def to_native
	if @sarah.rnd_size == 3 then native = []
	elsif @sarah.seq_size == 0 then native = {}
	else native = Sarah.new
	end
	@sarah.each do |key, value|
	    # Exclude some permanent namespace attributes
	    native[key] = value.to_native unless key =~ /^[_@$]$/
	end
	native
    end

    #
    # Clear values except for permanent namespace attributes.
    #
    def clear
	super
	@sarah.rnd['_'] = @parameters
	@sarah.rnd['@'] = @root
	@sarah.rnd['^'] = @parent if @parent
	@sarah.rnd['$'] = self
	self
    end

    #
    # Search for the specified item in the current namespace or above.
    #
    def find_item (name)
	namespace = self
	while namespace
	    break if namespace.has_item? name
	    namespace = namespace.parent
	end
	namespace
    end

    #
    # Template string-value for method
    #
    def method_string
	@method_string ||= @template.factory :string, @method
    end

    def get_value (opts = {})
	case opts[:method]
	when 'array', '*' # anonymous array
	    opts[:parameters] ? opts[:parameters] :
	      @template.factory(:parameters)
	when 'false' then @template.factory :boolean, false
	when 'if' then do_if opts
	when 'loop' then do_loop opts
	when 'method' then method_string
	when 'nil' then @template.nil
	when 'target' then @target || @template.nil
	when 'true' then @template.factory :boolean, true
	when 'use' then do_use opts
	when 'var' then do_add_names opts
	else super
	end
    end

    # Type (for :missing_method callback)
    def type; :namespace; end

    # Add new namespace names with nil or specific values
    #
    def do_add_names (opts)
	params = opts[:parameters]
	if params.positional.size
	    tnil = @template.nil
	    params.positional.each { |item| set_item(item.to_native, tnil) }
	end
	if params.named.size
	    params.named.each { |item, val| set_item(item, val) }
	end
	@template.nil
    end

    # Implement conditionals
    def do_if (opts)
	if params = opts[:parameters]
	    params.positional.each_slice(2) do |e1, e2|
		e1 = e1.get_value :method => 'call'

		#
		# Return the "else" value, e1, in the absence of
		# a condition/result value pair.
		#
		return e1 unless e2

		# Return the e2 result if e1 evaluates to true
		return e2.get_value(:method => 'call') if e1.to_boolean
	    end
	end
	@template.nil
    end

    def do_loop (opts)
	results = @template.factory :array
	if params = opts[:parameters] and params.positional.size > 1
	    params = params.positional
	    while params[0].get_value(:method => 'call').to_boolean
		@template.use :iterations
		results.sarah.push params[1].get_value(:method => 'call')
		break if params[2] and
		  !params[2].get_value(:method => 'call').to_boolean
	    end
	end
	results
    end

    def do_use (opts)
	tpl = @template
	if loader = tpl.options[:loader] and
	  params = opts[:parameters] and params.positional.size > 0
	    name = params.positional[0].get_value.to_text
	    if !tpl.used[name]
		tpl.use :use
		tpl.used[name] = true
		result = loader.call(tpl, name)
		tpl.parse_template(tpl.get_tokens result).get_value if
		  result.kind_of? String
	    end
	end
	tpl.nil
    end

end
