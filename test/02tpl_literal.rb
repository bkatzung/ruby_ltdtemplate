$LOAD_PATH << '../lib/ltdtemplate'

require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate < MiniTest::Unit::TestCase

    def setup
	@tpl = LtdTemplate.new
    end

    def test_template_literals1
	@tpl.parse '<<>>'
	assert_equal '', @tpl.render

	@tpl.parse 'literal1'
	assert_equal 'literal1', @tpl.render

	@tpl.parse 'literal2<<>>'
	assert_equal 'literal2', @tpl.render

	@tpl.parse '<<>>literal3'
	assert_equal 'literal3', @tpl.render

	@tpl.parse 'literal<<>>4'
	assert_equal 'literal4', @tpl.render
    end

    def test_template_literals2
	@tpl.parse '<<<<>>'
	assert_equal '<<', @tpl.render

	@tpl.parse '<<>>>>'
	assert_equal '>>', @tpl.render

	@tpl.parse '<<<<>>>>'
	assert_equal '<<>>', @tpl.render

	@tpl.parse 'a<<b<<c>>d>>e'
	assert_equal 'a<<bd>>e', @tpl.render

    end

    def test_template_trim
	@tpl.parse " \n <<'x>>  \n  "
	assert_equal " \n x  \n  ", @tpl.render

	@tpl.parse " \n <<.'x>>  \n  "
	assert_equal "x  \n  ", @tpl.render

	@tpl.parse " \n <<'x.>>  \n  "
	assert_equal " \n x", @tpl.render

	@tpl.parse " \n <<.'x.>>  \n  "
	assert_equal "x", @tpl.render

	@tpl.parse " \n <<.>>  \n  "
	assert_equal "", @tpl.render
    end

end

# END
