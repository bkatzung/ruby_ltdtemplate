require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_01 < MiniTest::Unit::TestCase

    def setup
	@tpl = LtdTemplate.new
    end

    def test_imethods_user_api
	[
	  :set_classes, :parse, :render
	].each { |method| assert_respond_to @tpl, method }
    end

    def test_imethods_library_api
	[
	  :push_namespace, :pop_namespace, :use, :using, :get_tokens
	].each { |method| assert_respond_to @tpl, method }
    end

    def test_imethods_internal_api
	[
	  :check_limit
	].each { |method| assert_respond_to @tpl, method }
    end

end

# END
