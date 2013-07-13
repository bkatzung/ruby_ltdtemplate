class LtdTemplate; end

# LtdTemplate::Code - Base class for LtdTemplate code/value objects
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

class LtdTemplate::Code

    # @!attribute [r] tpl_methods
    # @return [Array<LtdTemplate::Value::Code_Block>]
    # The code blocks bound to non-array values.
    attr_reader :tpl_methods

    # Return a new factory object instance (or a singleton in some
    # subclasses, e.g. nil).
    #
    # @param args [Array] Class-specific initializer parameters.
    def self.instance (*args); self.new(*args); end

    # Initialize the object with a link to the associated template.
    #
    # @param template [LtdTemplate] The associated template object.
    def initialize (template)
	@template = template
	@tpl_methods = {}
    end

    # Does a non-array value have a particular template method?
    #
    # @param key [String] The (native) string for the method.
    # @return [Boolean]
    def has_item? (key); @tpl_methods.has_key? key; end

    # Return a non-array value's method code block (if set).
    #
    # @param key [String] The (native) string for the method.
    # @return [LtdTemplate::Value::Code_Block]
    def get_item (key)
	(@tpl_methods.has_key? key) ? @tpl_methods[key] :
	  @template.factory(:nil)
    end

    # Set a non-array value's method code block.
    #
    # @param key [String] The (native) string for the method.
    # @param value [LtdTemplate::Value::Code_Block] The code block
    #   for the method.
    def set_item (key, value); @tpl_methods[key] = value; end

    # No-op setting a value. (Typically only variables can change their
    # primary values.)
    #
    # @param value The value to set. (Ignored.)
    # @return [LtdTemplate::Code]
    def set_value (value); self; end

    # Is this value set? Always true except for unset variables.
    #
    # @return [true]
    def is_set?; true; end

    # Implement "=" (assignment). Note that set_value is a no-op except
    # for variables and array subscripts.
    #
    # @param opts [Hash] A hash of method options.
    # @option opts [LtdTemplate::Value::Parameters] :parameters The method
    #   parameters.
    # @return [LtdTemplate::Value::Nil]
    def do_set (opts)
	if params = opts[:parameters]
	    set_value(params.scalar? ? params.positional[0] : params)
	end
	@template.factory :nil
    end

    # Try to execute code-block methods bound to the object or object
    # class. Returns the return value from the code block or t-nil.
    def do_method (opts, class_name = nil)
	method = nil
	if name = opts[:method]
	    if @tpl_methods.has_key? name
		method = @tpl_methods[name]
	    elsif class_name
		class_var = @template.factory :variable, class_name
		method = class_var.target.tpl_methods[name] if
		  class_var.is_set?
	    end
	end
	if method
	    opts[:target] = self
	    method.get_value opts
	else
	    @template.factory :nil
	end
    end

end

# This is the parent namespace for value code classes.
class LtdTemplate::Value; end
