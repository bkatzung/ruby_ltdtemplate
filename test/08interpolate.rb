require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_08 < MiniTest::Unit::TestCase

    def setup
	@tpl = LtdTemplate.new
    end

    def test_interpolate1_slash
	@tpl.parse '<<a=(1,2)b=(a/)b.join(",">>'
	assert_equal '1,2', @tpl.render, "a=(1,2)b=(a/)b.join(,)"
	@tpl.parse '<<a=(1,2) $.*(a/,a/).join(",")>>'
	assert_equal "1,2,1,2", @tpl.render, "a=(1,2)$.*(a/,a/).join"
	@tpl.parse '<<a=(1,2) $.*(a).join(",") " " $.*(a/).join(",")>>'
	assert_equal "12 1,2", @tpl.render, "$.*(a).join $.*(a/).join"
    end

    def test_interpolate2_percent
	@tpl.parse '<<a=("key","value")b=(a%)b.each_rnd({_.join(";")})>>'
	assert_equal 'key;value', @tpl.render, 'a=(key,value) b=(a%)'
    end

    def test_interpolate3
	@tpl.parse <<'TPL'
<< a=(2, 3 .. 'a, 'a, 'x, 'a, 'y, 'a) b=(5, 6 .. 'b, 'b, 'x, 'b, 'y, 'b)
c=('c, 'c, 'x, 'c, 'y, 'c) d=(1, a/, 4, b/, 7, c%, 8 .. 'd, 'd, 'y, 'd) >>
TPL
	@tpl.render
	d = @tpl.namespace.get_item(?d).to_native
	assert_equal [1, 2, 3, 4, 5, 6, 7, 8], d.seq, "d (sequential)"
	assert_equal({ ?a => ?a, ?b => ?b, ?c => ?c, ?d => ?d,
	  ?x => ?c, ?y => ?d }, d.rnd, "d (random-access)")
    end

end

# END
