require 'minitest/autorun'
require 'ltdtemplate'

class TestLtdTemplate_03 < MiniTest::Unit::TestCase

    def setup
	@tpl1 = LtdTemplate.new
	@tpl2 = LtdTemplate.new
    end

    def test_nil
	nil1a = @tpl1.factory :nil
	nil1b = @tpl1.factory :nil
	assert_equal nil1a.object_id, nil1b.object_id, "Shared nil in tpl1"
	nil2a = @tpl2.factory :nil
	nil2b = @tpl2.factory :nil
	assert_equal nil2a.object_id, nil2b.object_id, "Shared nil in tpl2"
	refute_equal nil1a.object_id, nil2a.object_id,
	  "Different nil in tpl1, tpl2"
    end

    def test_boolean
	true1a = @tpl1.factory :boolean, true
	true1b = @tpl1.factory :boolean, true
	assert_equal true1a.object_id, true1b.object_id,
	  "Shared true in tpl1"
	true2a = @tpl2.factory :boolean, true
	true2b = @tpl2.factory :boolean, true
	assert_equal true2a.object_id, true2b.object_id,
	  "Shared true in tpl2"
	refute_equal true1a.object_id, true2a.object_id,
	  "Different true in tpl1, tpl2"

	false1a = @tpl1.factory :boolean, false
	false1b = @tpl1.factory :boolean, false
	assert_equal false1a.object_id, false1b.object_id,
	  "Shared false in tpl1"
	false2a = @tpl2.factory :boolean, false
	false2b = @tpl2.factory :boolean, false
	assert_equal false2a.object_id, false2b.object_id
	  "Shared false in tpl2"
	refute_equal false1a.object_id, false2a.object_id
	  "Different false in tpl1, tpl2"
    end

end

# END
