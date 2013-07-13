require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate < MiniTest::Unit::TestCase

    def test_loader
	loader = proc { |t, n| puts "using #{n}" }
	tpl = LtdTemplate.new :loader => loader
	tpl.parse '<<$.use("one")$.use("one")$.use("two")>>'
	print tpl.render
	print tpl.usage
    end

end
