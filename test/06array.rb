require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_06 < MiniTest::Unit::TestCase

    def setup
	@tpl = LtdTemplate.new
    end

    def test_create
	@tpl.parse '<<a=a.type" "a.size>>'
	assert_equal 'array 0', @tpl.render
	@tpl.parse '<<a=()a.type" "a.size>>'
	assert_equal 'array 0', @tpl.render
	@tpl.parse '<<a=(0)a.type>>'
	assert_equal 'number', @tpl.render
	@tpl.parse '<<a=(0..)a.type" "a.size>>'
	assert_equal 'array 1', @tpl.render
	@tpl.parse '<<a=(0,1)a.type" "a.size>>'
	assert_equal 'array 2', @tpl.render
    end

end

# END
