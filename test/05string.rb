require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_05 < MiniTest::Unit::TestCase

    def setup
	@tpl = LtdTemplate.new
    end

    def test_basic
	@tpl.parse '<<"str">>'
	assert_equal("str", @tpl.render, "literal")
	@tpl.parse '<<"str".type>>'
	assert_equal("string", @tpl.render, "type")
	@tpl.parse '<<"str"+("ing","value")>>'
	assert_equal("stringvalue", @tpl.render, "string +")
	@tpl.parse '<<"str"*(3)>>'
	assert_equal("strstrstr", @tpl.render, "string *")
    end

end

# END
