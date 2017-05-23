require_relative '../test_helper'

class StableSortTest < Minitest::Test
  context "#stable_sort_by" do
    should "preserve the original order if all sort the same" do
      list_to_sort = [:b, :d, :c, :a, :e, :f]

      assert_equal list_to_sort, list_to_sort.stable_sort_by { |c| 0 }
    end

    should "order by keys first and then position" do
      list_to_sort = [:b, :d, :c, :a, :e, :f]
      order = [:a, :b, :c]

      result = list_to_sort.stable_sort_by { |c| order.index(c) || order.length }
      assert_equal [:a, :b, :c, :d, :e, :f], result
    end

    should "order by keys only if needed" do
      list_to_sort = [:b, :d, :c, :a, :e, :f]
      result = list_to_sort.stable_sort_by { |c| c.to_s }
      assert_equal [:a, :b, :c, :d, :e, :f], result
    end
  end

  context "stable_sort" do
    should "preserve the original order if all sort the same" do
      list_to_sort = [:b, :d, :c, :a, :e, :f]

      assert_equal list_to_sort, list_to_sort.stable_sort { |first, second| 0 }
    end

    should "order by keys first and then position" do
      list_to_sort = [:b, :d, :c, :a, :e, :f]
      order = [:a, :b, :c]

      result = list_to_sort.stable_sort do |first, second|
        first_pos = order.index(first) || order.length
        second_pos = order.index(second) || order.length
        first_pos <=> second_pos
      end

      assert_equal [:a, :b, :c, :d, :e, :f], result
    end

    should "order by keys only if needed" do
      list_to_sort = [:b, :d, :c, :a, :e, :f]
      result = list_to_sort.stable_sort{ |first, second| first.to_s <=> second.to_s }
      assert_equal [:a, :b, :c, :d, :e, :f], result
    end
  end
end
