require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_09 < MiniTest::Unit::TestCase

    def test_use1
	loader = Proc.new { |tpl, name| "@#{name}=(0+(@#{name},1))" }
	tpl = LtdTemplate.new :loader => loader
	tpl.parse "<<$.use('ab)$.use('cd)$.use('ab)\",\".join(@ab,@cd)>>"
	assert_equal "1,1", tpl.render, "use ab, cd, ab counts => 1, 1"
    end

end

# END
