require 'test_helper'

class PaymentProfileRolloverTest < ActiveSupport::TestCase
  
  
  test "should create new entry from a changed payment profile" do
    payment_profiles(:payment_profiles_001).expected_payment_date = payment_profiles(:payment_profiles_001).expected_payment_date + 1.month
    payment_profiles(:payment_profiles_001).reason_for_date_change = 'My reason'
    payment_profiles(:payment_profiles_001).last_saved_by_id = users(:users_001).id
    
    assert_difference 'PaymentProfileRollover.count', +1 do
      PaymentProfileRollover.create_entry(payment_profiles(:payment_profiles_001))
    end
  end

  test '.profiles_rolled_over_in_to_month should return an Array of PaymentProfiles' do
    Delorean.time_travel_to('23rd May 2013') do
      assert_equal 1, PaymentProfileRollover.profiles_rolled_over_in_to_month(0).size
    end
  end

  test '.profiles_rolled_over_in_to_month should return an Array of PaymentProfiles objects' do
    Delorean.time_travel_to('23rd May 2013') do
      assert_equal PaymentProfile, PaymentProfileRollover.profiles_rolled_over_in_to_month(0).first.class
    end
  end

  
end
