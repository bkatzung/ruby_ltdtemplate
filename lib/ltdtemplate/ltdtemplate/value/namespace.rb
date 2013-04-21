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
	when 'method' then method_string
	when 'target' then @target || @template.factory(:nil)
	when 'true' then @template.factory :boolean, true
	when 'false' then @template.factory :boolean, false
	when 'nil' then @template.factory :nil
	when 'if' then do_if opts
	when 'loop' then do_loop opts
	else super
	end
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
	@template.factory :nil
    end

    def do_loop (opts)
	results = []
	if params = opts[:parameters] and params.positional.size > 1
	    params = params.positional
	    while params[0].get_value(:method => 'call').to_boolean
		@template.use :iterations
		results << params[1].get_value(:method => 'call')
		break if params[2] and !params[2].get_value(:method => 'call').
		  to_boolean
	    end
	end

	case results.size
	when 0 then @template.factory :nil
	when 1 then results[0]
	else @template.factory(:array).set_from_array(results)
	end
    end

end
