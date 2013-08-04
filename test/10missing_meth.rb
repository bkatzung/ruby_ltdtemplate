require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_10 < MiniTest::Unit::TestCase

    def test_missing_meth1
	miss_meth = Proc.new do |tpl, obj, opt|
	    tpl.factory :string, "#{obj.type}.#{opt[:method]};"
	end
	tpl = LtdTemplate.new :missing_method => miss_meth
	tpl.parse "<<$.*.abc 1.def '.ghi>>"
	assert_equal "array.abc;number.def;string.ghi;", tpl.render,
	  "missing method ary.abc, num.def, str.def"
    end

end

# END
