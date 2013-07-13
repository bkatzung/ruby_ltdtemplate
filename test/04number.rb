require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_04 < MiniTest::Unit::TestCase

    def setup
	@tpl = LtdTemplate.new
    end

    def test_imethods
	num = @tpl.factory :number
	[
	    :get_value, :to_boolean, :to_native, :to_text
	].each { |method| assert_respond_to num, method }
    end

    def test_basic
	@tpl.parse '<<1>>'
	assert_equal("1", @tpl.render, "literal")
	@tpl.parse '<<1.type>>'
	assert_equal("number", @tpl.render, "type")
	@tpl.parse '<<1+(2,3)>>'
	assert_equal("6", @tpl.render, "1+2+3")
	@tpl.parse '<<1->>'
	assert_equal("-1", @tpl.render, "neg 1")
	@tpl.parse '<<1-(2,3)>>'
	assert_equal("-4", @tpl.render, "1-2-3")
	@tpl.parse '<<2*(3,4)>>'
	assert_equal("24", @tpl.render, "2*3*4")
	@tpl.parse '<<24/(2,3)>>'
	assert_equal("4", @tpl.render, "24/2/3")
    end

end

# END
