require_relative '../test_helper'
require 'invoca/utils'
require 'invoca/utils/remove_assert_nil_warning'

class RemoveAssertEqualNilTest < Minitest::Test
  should "allow assert_equal nil" do
    assert_equal nil, nil
  end
end

