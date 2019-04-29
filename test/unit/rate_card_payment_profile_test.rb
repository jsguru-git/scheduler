require 'test_helper'

class RateCardPaymentProfileTest < ActiveSupport::TestCase
  
  
  test "should check that a rate card and payment profile belong to the same account" do
    rate_card_payment_profile = rate_card_payment_profiles(:one)
    assert_equal true, rate_card_payment_profile.valid?
    rate_card_payment_profile.rate_card_id = rate_cards(:rate_cards_006).id
    
    assert_equal false, rate_card_payment_profile.valid?
  end
  
  
end
