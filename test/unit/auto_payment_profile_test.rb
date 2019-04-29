require 'test_helper'

class AuotPaymentProfileTest < ActiveModel::TestCase
  
  # Test complience with ActiveModel
  include ActiveModel::Lint::Tests

  
  def setup
    @model = AutoPaymentProfile.new
    @auto_payment_profile = AutoPaymentProfile.new
    @auto_payment_profile.set_defaults_for(projects(:projects_001))
  end
  
  
  test "should check start date is before end date" do
    assert_equal true, @auto_payment_profile.valid?
    
    @auto_payment_profile.end_date = @auto_payment_profile.start_date - 1.day
      
    assert_equal false, @auto_payment_profile.valid?
    assert @auto_payment_profile.errors[:end_date].present?
  end
  
  
  test "should assign params to vars correctly on initialize" do
    start_date = Time.new(2012,5,24).to_date
		end_date = start_date + 20.days
		
    @auto_payment_profile1 = AutoPaymentProfile.new('start_date' => start_date.to_s, 'end_date' => end_date.to_s, 'frequency' => '2')
    assert_equal start_date, @auto_payment_profile1.start_date
    assert_equal '2', @auto_payment_profile1.frequency
  end
  
  
  test "should set defaults" do
    @auto_payment_profile1 = AutoPaymentProfile.new
    @auto_payment_profile1.set_defaults_for(projects(:projects_001))
    
    start_date = Time.new(2012,5,23).to_date
    end_date = Time.new(2012,6,30).to_date
    
    assert_equal start_date, @auto_payment_profile1.start_date
    assert_equal end_date, @auto_payment_profile1.end_date
    assert_equal '0', @auto_payment_profile1.frequency
  end
  
  
  test "Should check if can generate from schedule" do
    assert_equal true, @auto_payment_profile.can_generate_from_scheulde_for(projects(:projects_001))
    assert_equal false, @auto_payment_profile.can_generate_from_scheulde_for(projects(:projects_012))
  end
  
  
  test "should create all payment stages for a project" do
    @auto_payment_profile.frequency = '2'
    payment_profiles = @auto_payment_profile.create_payment_stages_for(projects(:projects_001))
    
    assert_equal 6, payment_profiles.length
  end
  
  
end