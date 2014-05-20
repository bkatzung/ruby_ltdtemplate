# LtdTemplate::Code - Base class for LtdTemplate code objects
#
# @author Brian Katzung (briank@kappacs.com), Kappa Computer Solutions, LLC
# @copyright 2013-2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate'

class LtdTemplate::Code

    # All derived classes are initialized with the template object and
    # handle their own template methods.
    extend LtdTemplate::Consumer
    include LtdTemplate::Method_Handler

    # Initialize the object with a link to the associated template.
    #
    # @param template [LtdTemplate] The associated template object.
    def initialize (template); @template = template; end

    def inspect
	"#<#{self.class.name}##{self.object_id} for #{@template.inspect}>"
    end

    # Shortcut to rubyversed in the template.
    def rubyversed (obj); @template.rubyversed(obj); end

end

# END
