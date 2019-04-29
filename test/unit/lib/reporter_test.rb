# Report generator tests
require 'test_helper'
require 'reporter'

class ReporterTest < ActiveSupport::TestCase

   def setup
     @user     = users(:users_001)
     @reporter = Reporter::TimeReport.new(@user.id)
     @timing   = timings(:one)
   end

   test "user instance variable is accessible" do
      assert_respond_to @reporter, :user
   end

   test "should format date correctly" do
      t = Time.utc(2012,11,12)
      assert_equal "Monday 12 November 2012", @reporter.format(t)
   end

   test "get_data should not raise errors" do
     assert_nothing_raised do
       @reporter.get_data(@timing)
     end
   end

   test "get_data should returns an object" do
     assert_kind_of Object, @reporter.get_data(@timing)
   end

   test "to_csv should return a csv file" do
     start      = Date.today
     end_date   = Date.today - 1.week
     assert_kind_of String, @reporter.to_csv(start, end_date)
   end

   test "calculate_total" do

   end

   test "working_day_duration finds duration in minutes" do
     assert_equal 480, @reporter.working_day_duration
   end

   test "expected_time" do
     @reporter.stubs(:working_day_duration).returns(480)
     assert_equal 480, @reporter.expected_time(1)
     assert_equal 960, @reporter.expected_time(2)
   end

   test "format_result" do
     time = '02 hours 23 minutes'
     assert_equal '2 hours 23 minutes', @reporter.format_result(time)
   end

   test "remove_leading_zero should strip leading zero" do
     assert_equal "0", @reporter.remove_leading_zero("00")
     assert_equal "1", @reporter.remove_leading_zero("01")
     assert_equal "12", @reporter.remove_leading_zero("12")
   end
end

