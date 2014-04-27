require 'minitest/autorun'
require 'ltdtemplate'
require 'ltdtemplate/value/nil'

class TestLtdTemplate_11 < MiniTest::Unit::TestCase

    def test_classes1
	LtdTemplate.set_classes :nil => Nil1
	tpl = LtdTemplate.new
	tpl.parse '<<$.nil.type>>'
	assert_equal 'nil1', tpl.render, 'nil type after class class change'

	tpl = LtdTemplate.new
	tpl.set_classes :nil => Nil2
	tpl.parse '<<$.nil.type>>'
	assert_equal 'nil2', tpl.render, 'nil type after instance class change'

	tpl = LtdTemplate.new
	tpl.parse '<<$.nil.type>>'
	assert_equal 'nil1', tpl.render, 'recheck nil type after class change'
    end

end

class Nil1 < LtdTemplate::Value::Nil

    def get_value (opts = {})
	case opts[:method]
	when 'type' then @template.factory :string, 'nil1'
	else super
	end
    end

end

class Nil2 < LtdTemplate::Value::Nil

    def get_value (opts = {})
	case opts[:method]
	when 'type' then @template.factory :string, 'nil2'
	else super
	end
    end

end

# END
