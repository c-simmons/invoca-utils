require_relative '../test_helper'
require 'invoca/utils/diff'

class DiffTest < Minitest::Test
  should "support .compare" do
    result = Invoca::Utils::Diff.compare(['b', 'o', 'b', 'c', 'a', 't', 's'], ['c', 'a', 't', 'c', 'h'] )
    assert_equal <<-EOF, result
- b
- o
- b
  c
  a
  t
- s
+ c
+ h
    EOF
  end
end
