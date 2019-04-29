require 'test_helper'

class PaymentProfileMailerTest < ActionMailer::TestCase
  
  test "rollover alert mail delivery" do
    email = PaymentProfileMailer.new_rollover_alert(payment_profile_rollovers(:one), 'info@fleetsutie.com').deliver
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal ['info@fleetsuite.com'], email.from
    assert_equal '[FS_dev] New FleetSuite payment profile rollover', email.subject
  end
  
end
