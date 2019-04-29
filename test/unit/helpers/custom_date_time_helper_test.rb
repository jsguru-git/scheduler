require 'test_helper'

class CustomDateTimeHelperTest < ActionView::TestCase


  test "no errors raised" do
    assert_nothing_raised do
      minute_duration_to_human_time(1, accounts(:accounts_001), 0)
    end
  end
  
  
  test "should output a human estimate in minutes" do
    human_string = minute_duration_to_human_time(1, accounts(:accounts_001), 0)
    assert_equal '0 hours 1 min', human_string
  end
  
  
  test "should output a human estimate in minutes as default" do
    human_string = minute_duration_to_human_time(62, accounts(:accounts_001))
    assert_equal '1 hour 2 mins', human_string
  end
  
  
  test "should output human time in days" do
    human_string = minute_duration_to_human_time(480, accounts(:accounts_001), 1)
    assert_equal '1 day', human_string
    
    human_string = minute_duration_to_human_time(960, accounts(:accounts_001), 1)
    assert_equal '2 days', human_string
  end
  
  
  test "should output human time in weeks" do
    human_string = minute_duration_to_human_time(2400, accounts(:accounts_001), 2)
    assert_equal '1 week', human_string
    
    human_string = minute_duration_to_human_time(4800, accounts(:accounts_001), 2)
    assert_equal '2 weeks', human_string
  end
  
  
  test "should output human time in months" do
    human_string = minute_duration_to_human_time(10285, accounts(:accounts_001), 3)
    assert_equal '1 month', human_string
    
    human_string = minute_duration_to_human_time(20571, accounts(:accounts_001), 3)
    assert_equal '2 months', human_string
  end
  
  
  test "should output human time in days with decimal" do
    human_string = minute_duration_to_human_time(480, accounts(:accounts_001), 1, 1)
    assert_equal '1.0 day', human_string
    
    human_string = minute_duration_to_human_time(1060, accounts(:accounts_001), 1, 1)
    assert_equal '2.2 days', human_string
  end
  
  
  test "should output human time in weeks with decimal" do
    human_string = minute_duration_to_human_time(2400, accounts(:accounts_001), 2, 1)
    assert_equal '1.0 week', human_string
    
    human_string = minute_duration_to_human_time(5800, accounts(:accounts_001), 2, 1)
    assert_equal '2.4 weeks', human_string
  end
  
  
  test "should output human time in months with decimal" do
    human_string = minute_duration_to_human_time(10285, accounts(:accounts_001), 3, 1)
    assert_equal '1.0 month', human_string
    
    human_string = minute_duration_to_human_time(25571, accounts(:accounts_001), 3, 1)
    assert_equal '2.5 months', human_string
  end

 
  test "minute_duration_to_human_time should raise InvalidScale" do
    assert_raises InvalidScale do
      minute_duration_to_human_time(10285, accounts(:accounts_001), 4, 1)
    end    
  end

  # minute_duration_to_short_human_time
  test 'minute_duration_to_short_human_time should format correctly' do
    assert_match /\d\d:\d\d/, minute_duration_to_short_human_time(53)
  end

  test 'minute_duration_to_short_human_time should remain in minutes below 60 mins' do
    assert_equal '00:53', minute_duration_to_short_human_time(53)
  end

  test 'minute_duration_to_short_human_time should have leading zeros' do
    assert_match /\d\d:\d\d/, minute_duration_to_short_human_time(5)
  end

  test 'minute_duration_to_short_human_time should include hours value above 60 mins' do
    assert_equal '01:05', minute_duration_to_short_human_time(65)
  end

  test 'minute_duration_to_short_human_time should round negative values correctly' do
    assert_equal '-01:05', minute_duration_to_short_human_time(-65)
  end

end
