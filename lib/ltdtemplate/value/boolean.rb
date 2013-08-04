# LtdTemplate::Value::Boolean - Represents true/false in an LtdTemplate
#
# @author Brian Katzung <briank@kappacs.com>, Kappa Computer Solutions, LLC
# @copyright 2013 Brian Katzung and Kappa Computer Solutions, LLC
# @license MIT License

require 'ltdtemplate/code'

class LtdTemplate::Value::Boolean < LtdTemplate::Code

    # Use one shared true value and one shared false value per template.
    def self.instance (template, bool)
	template.factory_singletons[bool ? :bool_true : :bool_false] ||=
	  self.new(template, bool)
    end

    def initialize (template, bool)
	super template
	@bool = bool
    end

    def to_boolean; @bool; end
    def to_native; @bool; end
    def to_text; ''; end

    def get_value (opts = {})
	case opts[:method]
	when nil, 'call' then self
	when 'class' then @template.factory :string, 'Boolean'
	when 'str', 'string' then @template.factory :string,
	  (@bool ? 'true' : 'false')
	when 'type' then @template.factory :string, 'boolean'
	when '+', '|', 'or' then do_or opts
	when '*', '&', 'and' then do_and opts
	when '!', 'not' then do_not opts
	else do_method opts, 'Boolean'
	end
    end

    # Type (for :missing_method callback)
    def type; :boolean; end

    # Implement +/| (or):
    # bool|(bool1, ..., boolN)
    # True if ANY boolean is true. Evaluates {} blocks until true.
    def do_or (opts)
	if not @bool and params = opts[:parameters]
	    params.positional.each do |tval|
		return @template.factory :boolean, true if
		  tval.get_value(:method => 'call').to_boolean
	    end
	end
	self
    end

    # Implement */& (and):
    # bool&(bool1, ..., boolN)
    # True if ALL booleans are true. Evaluates {} blocks until false.
    def do_and (opts)
	if @bool and params = opts[:parameters]
	    params.positional.each do |tval|
		return @template.factory :boolean, false unless
		  tval.get_value(:method => 'call').to_boolean
	    end
	end
	self
    end

    # Implement ! (not):
    # bool!(bool1, ..., boolN)
    # True if ALL booleans are false. Evaluates {} blocks until true.
    def do_not (opts)
	if !@bool and params = opts[:parameters]
	    params.positional.each do |tval|
		return @template.factory :boolean, false if
		  tval.get_value(:method => 'call').to_boolean
	    end
	end
	@template.factory :boolean, !@bool
    end

end
