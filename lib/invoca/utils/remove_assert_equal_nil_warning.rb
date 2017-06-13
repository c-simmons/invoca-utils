
# Get rid of the super-annoying paternalistic warning about using assert_nil when the first argument is nil.
module Invoca
  module Utils
    module RemoveAssertEqualNilWarning
      def assert_equal(exp, act, msg = nil)
        if exp.nil?
          assert_nil(act,msg)
        else
          super
        end
      end
    end
  end
end

_ = ActiveSupport::TestCase
class Minitest::Test
  prepend ::Invoca::Utils::RemoveAssertEqualNilWarning
end
