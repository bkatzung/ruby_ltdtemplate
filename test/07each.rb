require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_07 < MiniTest::Unit::TestCase

    def setup
	@tpl = LtdTemplate.new
    end

    def test_each
	@tpl.parse <<'TPL'
<<a=(1,2,3..'four,4,'five,5,'six,6,7,7)
a.each({ $.*($.method,$_[0].type,$_[0],$_[1]).join(",") }).join(";")
.>>
TPL
	expected = {}
	%w(
	each_seq,number,0,1
	each_seq,number,1,2
	each_seq,number,2,3
	each_rnd,string,four,4
	each_rnd,string,five,5
	each_rnd,string,six,6
	each_rnd,number,7,7
	).each { |exp| expected[exp] = nil }
	actual = {}
	@tpl.render.split(?;).each { |res| actual[res] = nil }
	assert_equal(expected, actual, "array.each")
    end

    def test_each_rnd
	@tpl.parse <<'TPL'
<<a=(1,2,3..'four,4,'five,5,'six,6,7,7)
a.each_rnd({ $.*($.method,$_[0].type,$_[0],$_[1]).join(",") }).join(";")
.>>
TPL
	expected = {}
	%w(
	each_rnd,string,four,4
	each_rnd,string,five,5
	each_rnd,string,six,6
	each_rnd,number,7,7
	).each { |exp| expected[exp] = nil }
	actual = {}
	@tpl.render.split(?;).each { |res| actual[res] = nil }
	assert_equal(expected, actual, "array.each_rnd")
    end

    def test_each_seq
	@tpl.parse <<'TPL'
<<a=(1,2,3..'four,4,'five,5,'six,6,7,7)
a.each_seq({ $.*($.method,$_[0].type,$_[0],$_[1]).join(",") }).join(";")
.>>
TPL
	expected = {}
	%w(
	each_seq,number,0,1
	each_seq,number,1,2
	each_seq,number,2,3
	).each { |exp| expected[exp] = nil }
	actual = {}
	@tpl.render.split(?;).each { |res| actual[res] = nil }
	assert_equal(expected, actual, "array.each_seq")
    end

end

# END
