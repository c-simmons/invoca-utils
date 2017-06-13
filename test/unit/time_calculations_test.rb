require_relative '../test_helper'
require 'invoca/utils'

class TimeCalculationsTest < Minitest::Test
  context "beginning_of_hour" do
    Time.zone = 'Pacific Time (US & Canada)'
    [
      Time.now,
      Time.zone.now,
      Time.local(2009),
      Time.local(2009,3,4,5),
      Time.local(2001,12,31,23,59),
      Time.local(1970,1,1)
    ].each_with_index do |time, index|
      should "give back a time with no minutes, seconds, or msec: #{time} (#{index})" do
        t = time.beginning_of_hour
        assert_equal t.year,  time.year
        assert_equal t.month, time.month
        assert_equal t.day,   time.day
        assert_equal t.hour,  time.hour
        assert_equal 0, t.min
        assert_equal 0, t.sec
        assert_equal 0, t.usec
      end
    end
  end

  context "end_of_day_whole_sec" do
    should "return the end of day with whole_sec" do
      t = Time.now
      end_of_day = t.end_of_day
      end_whole_sec = t.end_of_day_whole_sec
      assert_equal 0.0, end_whole_sec.usec
      assert_equal end_of_day.to_i, end_whole_sec.to_i
      assert_equal end_of_day.sec, end_whole_sec.sec
    end
  end
end
