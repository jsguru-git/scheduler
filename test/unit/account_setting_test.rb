require 'test_helper'

class AccountSettingTest < ActiveSupport::TestCase


    test "has an account" do
        account_settings(:account_settings_001).account_id = nil
        assert_equal account_settings(:account_settings_001).valid?, false
    end


    test "mark_as_reached_limit_email_sent" do
        account_settings(:account_settings_001).mark_as_reached_limit_email_sent
        assert_equal account_settings(:account_settings_001).reached_limit_email_sent, true
    end


    test "mark_as_reached_limit_email_not_sent" do
        account_settings(:account_settings_001).mark_as_reached_limit_email_not_sent
        assert_equal account_settings(:account_settings_001).reached_limit_email_sent, false 
    end


    test "working end time must be greater than start time" do
        account_settings(:account_settings_001).working_day_start_time = '09:15:00'
        account_settings(:account_settings_001).working_day_end_time = '09:00:00'
        assert_equal false, account_settings(:account_settings_001).valid?
    end


    test "should get working day duration in minutes" do
        hours = account_settings(:account_settings_001).working_day_duration_minutes
        assert_equal 480, hours
    end


    test "should update common project id but fail due to task belonging to different account" do
        account_setting = account_settings(:account_settings_001)
        account_setting.common_project_id = projects(:projects_011).id
        account_setting.save
        assert account_setting.errors[:common_project_id].present?
    end
       
       
    test "should check if monday is a working day" do
      account_setting = account_settings(:account_settings_001)
      assert_equal '1', account_setting.monday
    end
    
    
    test "should get the number of days worked in a week" do
      account_setting = account_settings(:account_settings_001)
      assert_equal 5, account_setting.number_of_days_worked_in_a_week
    end
    
    
    test "should validate at least one day is selected" do
      account_setting = account_settings(:account_settings_001)
      account_setting.working_days = {:sunday => '0', :monday => '0', :tuesday => '0', :wednesday => '0', :thursday => '0', :friday => '0', :saturday => '0'}
      account_setting.save
      assert account_setting.errors[:working_days].present?
    end
    
    
    test "should get the number of mins worked in a week" do
      account_setting = account_settings(:account_settings_001)
      assert_equal 2400, account_setting.number_of_minutes_worked_in_a_week
      
      account_setting = account_settings(:account_settings_002)
      assert_equal 3360, account_setting.number_of_minutes_worked_in_a_week
    end
    
    
    test "should get the number of mins worked in a month" do
      account_setting = account_settings(:account_settings_001)
      assert_equal 10260, account_setting.number_of_minutes_worked_in_a_month
    end

    test 'expected_minutes_worked should return 0 if day is a non working day' do
      assert_equal 0, account_settings(:account_settings_001).expected_minutes_worked(Date.parse('2013-08-31'))
    end

    test 'expected_minutes_worked should normal minutes if day is a working day' do
      normal_minutes = account_settings(:account_settings_001).working_day_duration_minutes

      assert_equal normal_minutes, account_settings(:account_settings_001).expected_minutes_worked(Date.parse('2013-08-30'))
    end
    
    test "should check if scheule email needs sending for daily mails" do
      account_settings(:account_settings_001).schedule_mail_frequency = 0
      account_settings(:account_settings_001).save!
      
      assert account_settings(:account_settings_001).should_send_email?(:schedule)
      
      account_settings(:account_settings_001).schedule_mail_last_sent_at = (Time.now - 25.hours)
      account_settings(:account_settings_001).save!
      
      assert account_settings(:account_settings_001).should_send_email?(:schedule)
      
      account_settings(:account_settings_001).schedule_mail_last_sent_at = Time.now
      account_settings(:account_settings_001).save!
      
      assert_equal false, account_settings(:account_settings_001).should_send_email?(:schedule)
    end
    
    
    test "should check if scheule email needs sending for weekly mails" do
      account_settings(:account_settings_001).schedule_mail_frequency = 1
      account_settings(:account_settings_001).save!
      t = Time.now.beginning_of_week.to_date
      Date.stubs(:today).returns(t)
      
      assert account_settings(:account_settings_001).should_send_email?(:schedule)
      
      account_settings(:account_settings_001).schedule_mail_last_sent_at = (Time.now - 2.weeks)
      account_settings(:account_settings_001).save!
      
      assert account_settings(:account_settings_001).should_send_email?(:schedule)
      
      account_settings(:account_settings_001).schedule_mail_last_sent_at = Time.now
      account_settings(:account_settings_001).save!
      
      assert_equal false, account_settings(:account_settings_001).should_send_email?(:schedule)
    end
    
    
    test "should check if scheule email needs sending for monthly mails" do
      account_settings(:account_settings_001).schedule_mail_frequency = 2
      account_settings(:account_settings_001).save!
      t = Time.now.beginning_of_month.to_date
      Date.stubs(:today).returns(t)
      
      assert account_settings(:account_settings_001).should_send_email?(:schedule)
      
      account_settings(:account_settings_001).schedule_mail_last_sent_at = (Time.now - 2.months)
      account_settings(:account_settings_001).save!
      
      assert account_settings(:account_settings_001).should_send_email?(:schedule)
      
      account_settings(:account_settings_001).schedule_mail_last_sent_at = Time.now
      account_settings(:account_settings_001).save!
      
      assert_equal false, account_settings(:account_settings_001).should_send_email?(:schedule)
    end
    
    
    test "should send schedule mail email" do
      account_settings(:account_settings_001).schedule_mail_frequency = 0
      account_settings(:account_settings_001).save!
      
      assert_difference "ActionMailer::Base.deliveries.length", +1 do
        AccountSetting.send_schedule_mail
      end
    end
    
    
    test "should send expected invoice mail email" do
      account_settings(:account_settings_001).expected_invoice_mail_frequency = 0
      account_settings(:account_settings_001).save!
      
      assert_difference "ActionMailer::Base.deliveries.length", +1 do
        AccountSetting.send_expected_invoice_mail
      end
    end
    
    test "should encrypt issue tracker username and password on save" do
      account_setting = account_settings(:account_settings_001)
      account_setting.updating_issue_tracker_credentails = true
      account_setting.issue_tracker_username = 'testtt'
      account_setting.issue_tracker_password = 'test'
      account_setting.issue_tracker_url = 'http://jira.com'
      assert account_setting.save!
      
      assert_not_equal 'testtt', account_setting.issue_tracker_username
      assert_not_equal 'test', account_setting.issue_tracker_password
    end
    
    
    test "should decrypt username and password" do
      account_setting = account_settings(:account_settings_001)
      account_setting.updating_issue_tracker_credentails = true
      account_setting.issue_tracker_username = 'testtt'
      account_setting.issue_tracker_password = 'test'
      account_setting.issue_tracker_url = 'http://jira.com'
      assert account_setting.save!
      
      assert_equal 'testtt', account_setting.issue_tracker_username_raw
      assert_equal 'test', account_setting.issue_tracker_password_raw
    end
    
end

