# LtdTemplate::Value::Namespace - Represents an LtdTemplate variable namespace
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'sarah'
require 'xkeys'
require 'ltdtemplate/value'

class LtdTemplate::Value::Namespace < Sarah

    include LtdTemplate::Value
    include XKeys::Hash

    attr_reader :tpl_method, :parameters, :parent, :root, :template
    attr_accessor :target

    def initialize (template, tpl_method, parameters, parent = nil)
	super template
	@tpl_method, @parameters = tpl_method, parameters
	@root = parent ? parent.root : self
	@parent = parent
	@target = nil
	clear()
    end

    # Clear values except for permanent namespace attributes.
    def clear
	super
	self['_'] = @parameters
	self['@'] = @root
	self['^'] = @parent if @parent
	self['$'] = self
	self
    end

    # Evaluate supported methods on namespaces.
    def evaluate (opts = {})
	case opts[:method]
	when nil, 'call' then self
	when 'array', '*' # anonymous array
	    opts[:parameters] ? opts[:parameters] : @template.factory(:array)
	when 'class' then 'Namespace'
	when 'false' then false
	when 'if' then do_if opts
	when 'loop' then do_loop opts
	when 'method' then @tpl_method
	when 'nil' then nil
	when 'target' then @target
	when 'true' then true
	when 'type' then 'namespace'
	when 'use' then do_use opts
	when 'var' then do_add_names opts
	else super opts
	end
    end

    # Search for the specified item in the current namespace or above.
    def find_item (name)
	namespace = self
	while namespace
	    break if namespace.has_key? name
	    namespace = namespace.parent
	end
	namespace
    end

    # Namespaces do not generate template output.
    def tpl_text; ''; end

    # Auto-vivicate arrays in namespaces.
    def xkeys_new (*args); @template.factory :array; end

    ###################################################

    # Add new namespace names with nil or specific values.
    # $.var(name1, ..., nameN .. key1, val1, ..., keyN, valN)
    def do_add_names (opts)
	if params = opts[:parameters]
	    params.each(:seq) { |idx, val| self[val] = nil }
	    params.each(:nsq) { |key, val| self[key] = val }
	end
	nil
    end

    # Implement conditionals
    # $.if({test1}, {result1}, ..., {testN}, {resultN}, {else_value})
    def do_if (opts)
	if params = opts[:parameters]
	    params.values(:seq).each_slice(2) do |pair|
		e1 = rubyversed(pair[0]).evaluate :method => 'call'

		#
		# Return the "else" value, e1, in the absence of
		# a condition/result value pair.
		#
		return e1 if pair.size == 1

		# Return the e2 result if e1 evaluates to true
		if rubyversed(e1).tpl_boolean
		    return rubyversed(pair[1]).evaluate :method => 'call'
		end
	    end
	end
	nil
    end

    # Implement loops
    # $.loop({pre_test}, {body})
    # $.loop({pre_test}, {body}, {post_test})
    def do_loop (opts)
	results = @template.factory :array
	if (params = opts[:parameters]) && params.size(:seq) > 1
	    while rubyversed(params[0]).evaluate(:method => 'call').
	      in_rubyverse(@template).tpl_boolean
		@template.use :iterations
		results.push rubyversed(params[1]).evaluate :method => 'call'
		break if params.size(:seq) > 2 && !rubyversed(params[2]).
		  evaluate(:method => 'call').in_rubyverse(@template).
		  tpl_boolean
	    end
	end
	results
    end

    # Load external resources
    def do_use (opts)
	tpl = @template
	if (loader = tpl.options[:loader]) && (params = opts[:parameters]) &&
	  params.size(:seq) > 0
	    name = params[0]
	    if !tpl.used[name]
		tpl.use :use
		tpl.used[name] = true
		result = loader.call(tpl, name)
		tpl.parse_template(tpl.get_tokens result).evaluate if
		  result.kind_of? String
	    end
	end
	nil
    end

end

# END
