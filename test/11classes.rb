require 'minitest/autorun'
require 'ltdtemplate'
require 'ltdtemplate/proxy/nil'

class TestLtdTemplate_11 < MiniTest::Unit::TestCase

    def test_classes1
	LtdTemplate.set_classes :nil_proxy => Nil1
	tpl = LtdTemplate.new
	tpl.parse '<<$.nil.type>>'
	assert_equal 'nil1', tpl.render, 'nil type after class class change'

	tpl = LtdTemplate.new
	tpl.set_classes :nil_proxy => Nil2
	tpl.parse '<<$.nil.type>>'
	assert_equal 'nil2', tpl.render, 'nil type after instance class change'

	tpl = LtdTemplate.new
	tpl.parse '<<$.nil.type>>'
	assert_equal 'nil1', tpl.render, 'recheck nil type after class change'
    end

end

class Nil1 < LtdTemplate::Proxy::Nil

    def evaluate (opts = {})
	case opts[:method]
	when 'type' then 'nil1'
	else super
	end
    end

end

class Nil2 < LtdTemplate::Proxy::Nil

    def evaluate (opts = {})
	case opts[:method]
	when 'type' then 'nil2'
	else super
	end
    end

end

# END
