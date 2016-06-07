require_relative '../test_helper'

class MapCompactTest < Minitest::Test
  should "map_compact" do
    assert_equal [1, 9], [1, 2, nil, 3, 4].map_compact { |item| item**2 if (nil == item ? nil : item.odd?) }
  end

  should "map_compact to empty if nothing matches" do
    assert_equal [], {:a => 'aaa', :b => 'bbb'}.map_compact { |key, value| value if key == :c }
  end

  should "map_compact a hash" do
    assert_equal ['bbb'], {:a => 'aaa', :b => 'bbb'}.map_compact { |key, value| value if key == :b }
  end

  should "map_compact empty collection" do
    assert_equal [], [].map_compact { |item| true }
  end

  should "not map_compact false" do
    assert_equal [false], [nil, false].map_compact { |a| a }
  end
end
