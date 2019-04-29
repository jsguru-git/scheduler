require 'test_helper'

class Invoice::PaymentProfilesHelperTest < ActionView::TestCase
  
  
  test "should return the saved year when there have been no changes to the instance" do
    year = data_attr_for_ori_year payment_profiles(:payment_profiles_001)
    assert_equal 2013, year
  end
  
  
  test "should return the saved year when there have been changes to the instance" do
    payment_profiles(:payment_profiles_001).expected_payment_date = payment_profiles(:payment_profiles_001).expected_payment_date + 1.year
    year = data_attr_for_ori_year payment_profiles(:payment_profiles_001)
    assert_equal 2013, year
  end
  
  
  test "should return the saved month when there have been no changes to the instance" do
    month = data_attr_for_ori_month payment_profiles(:payment_profiles_001)
    assert_equal 3, month
  end
  
  
  test "should return the saved month when there have been changes to the instance" do
    payment_profiles(:payment_profiles_001).expected_payment_date = payment_profiles(:payment_profiles_001).expected_payment_date + 1.month
    month = data_attr_for_ori_month payment_profiles(:payment_profiles_001)
    assert_equal 3, month
  end
  
  
end
