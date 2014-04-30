# LtdTemplate::Proxy - Common code for LtdTemplate value proxies
#
# @author Brian Katzung (briank@kappacs.com), Kappa Computer Solutions, LLC
# @copyright 2014 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/value'

class LtdTemplate::Proxy

    include LtdTemplate::Value

    def initialize (template, original)
	super template
	@original = original
    end

    # Return the Rubyverse original object.
    def rubyverse_original; @original; end

    # Shortcut to rubyversed in the tamplate.
    def rubyversed (obj); @template.rubyversed obj; end

end

# END
