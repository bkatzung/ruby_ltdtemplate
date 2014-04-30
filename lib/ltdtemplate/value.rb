# LtdTemplate::Value - Common code for LtdTemplate value objects
#
# @author Brian Katzung (briank@kappacs.com), Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate'

module LtdTemplate::Value

    class Code_Block; end

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

    # Shortcut to rubyversed in the template.
    def rubyversed (obj); @template.rubyversed(obj); end

    # Default boolean value is true
    def tpl_boolean; true; end

    ##################################################

    # Set or get run-time methods.
    #
    # @param opts [Hash] A hash of method options.
    # @return [nil]
    def do_methods (opts)
	if params = opts[:parameters]
	    params.values(:seq).each_slice(2) do |pair|
		return @runtime_methods[pair[0]] if pair.size == 1
		if pair[1].nil? then @runtime_methods.delete pair[0]
		else @runtime_methods[pair[0]] = pair[1]
		end
	    end
	end
	nil
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
	if method.is_a? LtdTemplate::Value::Code_Block
	    opts[:target] = self
	    rubyversed(method).evaluate opts
	elsif !method.nil? then method
	elsif mmproc = @template.options[:missing_method]
	    mmproc.call(@template, self, opts)
	else nil
	end
    end

end

# END
