require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_00 < MiniTest::Unit::TestCase

    def test_cmethod_new
	assert_respond_to LtdTemplate, :new
    end

    def test_cmethod_set_classes
	assert_respond_to LtdTemplate, :set_classes
    end

    def test_new_1
	assert LtdTemplate.new, "Failed to create new LtdTemplate"
    end

end

# END
