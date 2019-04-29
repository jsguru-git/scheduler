require 'test_helper'

class AccountAccountComponentTest < ActiveSupport::TestCase
    
  
  #
  #
  test "should deliver trial email 15 days before expiry" do
    account = accounts(:accounts_004)
    
    account.trial_expires_at = Date.today + 16.days
    account.save!
    account.reload
    
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
      assert_equal false, account.account_trial_email.email_1_sent?
    end
    
    account.trial_expires_at = Date.today + 15.days
    account.save!
    account.reload

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      account.account_trial_email.deliver_trial_emails
      assert account.account_trial_email.email_1_sent?
    end
    
    # Check doesnt send email again
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
    end
  end
  
  
  #
  #
  test "should deliver trial email 2 days before expiry for accounts not used" do
    account = accounts(:accounts_004)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.account_trial_email.reload
    
    account.trial_expires_at = Date.today + 3.days
    account.save!
    account.reload
    
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
      assert_equal false, account.account_trial_email.email_3_sent?
    end
    
    account.trial_expires_at = Date.today + 2.days
    account.save!
    account.reload

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      account.account_trial_email.deliver_trial_emails
      account.reload
      assert account.account_trial_email.email_3_sent? # email marked as sent
      assert_equal 2, account.account_trial_email.trial_path # route 2 of email path taken
      assert_equal 14.days.from_now.day, account.trial_expires_at.day # extended trial date
    end
    
    # Check doesnt send email again
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
    end
  end
  
  
  #
  #
  test "should deliver trial email 2 days before expiry for accounts that have been used" do
    account = accounts(:accounts_004)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.projects.create!(:name => 'test another email project')
    account.account_trial_email.reload
    
    account.trial_expires_at = Date.today + 3.days
    account.save!
    account.reload
    
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
      assert_equal false, account.account_trial_email.email_2_sent?
    end
    
    account.trial_expires_at = Date.today + 2.days
    account.save!
    account.reload

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      account.account_trial_email.deliver_trial_emails
      account.reload
      assert account.account_trial_email.email_2_sent? # email marked as sent
      assert_equal 1, account.account_trial_email.trial_path # route 2 of email path taken
    end
    
    # Check doesnt send email again
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
    end
  end
  
  
  #
  #
  test "should deliver trial email 2 days before expiry for accounts that have not been used but trial has been extended" do
    account = accounts(:accounts_004)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.account_trial_email.update_attribute(:email_3_sent, true)
    account.projects.create!(:name => 'test another email project')
    account.account_trial_email.reload
    
    account.trial_expires_at = Date.today + 3.days
    account.save!
    account.reload
    
    assert account.account_trial_email.email_3_sent? # Should be set to already sent
    
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
      assert_equal false, account.account_trial_email.email_2_sent?
    end
    
    account.trial_expires_at = Date.today + 2.days
    account.save!
    account.reload

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      account.account_trial_email.deliver_trial_emails
      account.reload
      assert account.account_trial_email.email_2_sent? # email marked as sent
      assert_equal 1, account.account_trial_email.trial_path # route 2 of email path taken
    end
  end
  
  
  #
  #
  test "Should deliver trial expiry email for accounts that have been used" do
    account = accounts(:accounts_004)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.account_trial_email.update_attribute(:email_2_sent, true)
    account.account_trial_email.update_attribute(:trial_path, 1)
    account.projects.create!(:name => 'test another email project')
    account.account_trial_email.reload

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      account.account_trial_email.send_trial_expired_email
    end
  end
  
  
  #
  #
  test "Should deliver trial expiry email for accounts that have not been used" do
    account = accounts(:accounts_004)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.account_trial_email.update_attribute(:email_3_sent, true)
    account.account_trial_email.update_attribute(:trial_path, 2)
    account.projects.create!(:name => 'test another email project')
    account.account_trial_email.reload

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.send_trial_expired_email
    end
  end
  
  
  #
  #
  test "should deliver feedback email 5 days after trial expiry to non used accounts" do
    account = accounts(:accounts_004)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.account_trial_email.update_attribute(:email_3_sent, true)
    account.account_trial_email.update_attribute(:trial_path, 2)
    account.account_suspended = true
    account.save!
    account.reload
    account.account_trial_email.reload
    
    account.trial_expires_at = Date.today - 4.days
    account.save!
    account.reload
    
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
      assert_equal false, account.account_trial_email.email_4_sent?
    end
    
    account.trial_expires_at = Date.today + - 6.days # 5 days would = now and needs to be > than 5 days
    account.save!
    account.reload

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      account.account_trial_email.deliver_trial_emails
      account.reload
      assert account.account_trial_email.email_4_sent? # email marked as sent
    end
    
    # Check doesnt send email again
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
    end
  end
  
  
  #
  #
  test "should deliver feedback email 5 days after trial expiry to used accounts" do
    account = accounts(:accounts_004)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.account_trial_email.update_attribute(:email_1_sent, true)
    account.account_trial_email.update_attribute(:trial_path, 1)
    account.account_suspended = true
    account.save!
    account.reload
    account.account_trial_email.reload
    
    account.trial_expires_at = Date.today - 4.days
    account.save!
    account.reload
    
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
      assert_equal false, account.account_trial_email.email_4_sent?
    end
    
    account.trial_expires_at = Date.today + - 6.days # 5 days would = now and needs to be > than 5 days
    account.save!
    account.reload

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      account.account_trial_email.deliver_trial_emails
      account.reload
      assert account.account_trial_email.email_4_sent? # email marked as sent
    end
    
    # Check doesnt send email again
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      account.account_trial_email.deliver_trial_emails
    end
  end
  
  
end
