require 'test_helper'

class DaySplitterTest < ActiveSupport::TestCase

    test '#new should create new DaySplitter' do
      day_splitter = DaySplitter.new(example_working_days)

      assert_not_nil day_splitter.working_days
    end

    test '#working_day_ranges should return one value within working days' do
      day_splitter = DaySplitter.new(example_working_days)

      assert_equal 1, day_splitter.working_day_ranges(Date.parse('2014-01-06'), Date.parse('2014-01-09')).size
    end

    test '#working_day_ranges should return two values beyond working days' do
      day_splitter = DaySplitter.new(example_working_days)

      assert_equal 2, day_splitter.working_day_ranges(Date.parse('2014-01-06'), Date.parse('2014-01-15')).size
    end

    test '#working_day_ranges should not include non working days' do
      day_splitter = DaySplitter.new(example_working_days)

      days = day_splitter.working_day_ranges(Date.parse('2014-01-06'), Date.parse('2014-01-15')).map { |day| (day[:start_date]..day[:end_date]).map { |day|  day.strftime('%A') } }
      days = days.flatten.uniq

      assert_equal false, days.include?('Saturday')
    end

    def example_working_days
      { monday: '1', tuesday: '1', wednesday: '1', thursday: '1', friday: '1', saturday: '0', sunday: '1' }
    end

end
