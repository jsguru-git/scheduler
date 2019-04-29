# Report generator tests
require 'test_helper'
require 'timings'

class TimingsTest < ActiveSupport::TestCase

  test "shift_url nudges date forward 1 week" do
    before = "2013-07-07"
    after  = Timings.shift_url(:+, before, 7)
    assert_equal after, "2013-07-14"
  end

  test "shift_url nudges date back 1 week" do
    before = "2013-07-08"
    after  = Timings.shift_url(:-, before, 7)
    assert_equal after, "2013-07-01"
  end
end


