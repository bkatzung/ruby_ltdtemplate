# LtdTemplate::Value - Common code for LtdTemplate value objects
#
# @author Brian Katzung (briank@kappacs.com), Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate'

module LtdTemplate::Value

    class Explicit_Block; end

    # Classes that include this module are their own method handlers
    # and take the template as an initialization parameter.
    include LtdTemplate::Method_Handler
    def self.included (base); base.extend LtdTemplate::Consumer; end

    # @!attribute [r] runtime_methods
    # @return [Array<LtdTemplate::Value::Code_Block>]
    # This object's run-time methods.
    attr_reader :runtime_methods

    # Initialize the object with a link to the associated template.
    #
    # @param template [LtdTemplate] The associated template object.
    def initialize (template)
	@template = template
	@runtime_methods = {}
    end

    # Common operations for all values
    def evaluate (opts = {})
	case opts[:method]
	when 'methods' then do_methods opts
	else do_run_method opts
	end
    end

    # Avoid "spilling our guts" when inspected
    def inspect
	"#<#{self.class.name}##{self.object_id} for #{@template.inspect}>"
    end

    # The default method receiver is the result of evaluation.
    def receiver; self.evaluate; end

    # Shortcut to template rubyversed.
    def rubyversed (obj); @template.rubyversed(obj); end

    # Default boolean value is true
    def tpl_boolean; true; end

    ##################################################

    # Set or get run-time methods.
    #
    # @param opts [Hash] A hash of method options.
    # @return [nil]
    def do_methods (opts)
	params = opts[:parameters]
	if params && params.size == 2
	    runtime_methods[params[0]] = params[1]
	end
	if params && params.size > 0
	    runtime_methods[params[0]]
	else nil
	end
    end

    # Try to execute run-time methods bound to the object or object
    # class. Returns the return value from the code block or nil.
    #
    # @param opts [Hash] A hash of method options.
    def do_run_method (opts)
	method = nil
	if name = opts[:method]
	    method = @runtime_methods[name]
	    class_name = self.evaluate :method => 'class'
	    if !method && class_name
		class_var = @template.factory(:variable, class_name).evaluate
		method = rubyversed(class_var).runtime_methods[name] if class_var
	    end
	end
	if method.is_a? LtdTemplate::Value::Explicit_Block
	    opts[:target] = self
	    rubyversed(method).evaluate opts
	elsif method then method
	elsif mmproc = @template.options[:missing_method]
	    mmproc.call(@template, self, opts)
	else nil
	end
    end

end

# END
