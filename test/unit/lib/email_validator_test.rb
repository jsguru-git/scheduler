# Email validator tests

require 'test_helper'
require 'email_validator'

class EmailValidatorTest < ActiveSupport::TestCase

  test "should check allows one email address" do
    account_setting = account_settings(:account_settings_001)
    
    account_setting.rollover_alert_email = 'scott@arthurly.com'
    
    assert account_setting.valid?
  end
  
  test "should check allows multiple comma seperated email addresses" do
    account_setting = account_settings(:account_settings_001)
    
    account_setting.rollover_alert_email = 'scott@arthurly.com, stuart@arthurly.com,sam@arthurly.com'
    
    assert account_setting.valid?
  end
  
  test "should check does not allow invalid multiple comma seperated email addresses" do
    account_setting = account_settings(:account_settings_001)
    
    account_setting.rollover_alert_email = 'scott@arthurly.com, stuartarthurly.com,sam@arthurly.com'
    
    assert_equal false, account_setting.valid?
    assert account_setting.errors[:rollover_alert_email].present?
  end

end

