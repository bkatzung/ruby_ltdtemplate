# LtdTemplate::Value::Nil - Represents nil in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Value::Nil < LtdTemplate::Code

    # Use one shared instance per template.
    def self.instance (template, *args)
	template.factory_singletons[:nil] ||= self.new(template, *args)
    end

    def get_value (opts = {})
	case opts[:method]
	when 'type' then @template.factory :string, 'nil'
	else do_method opts
	end
    end

    def to_boolean; false; end
    def to_native; ''; end
    def to_text; ''; end

end
