require 'test_helper'

class ScheduleMailerTest < ActionMailer::TestCase
  
  test "schedule mail delivery" do
    start_date = Time.new(2012,5,24).to_date
		end_date = start_date + 20.days
    email = ScheduleMailer.schedule_mail(account_settings(:account_settings_001).account, account_settings(:account_settings_001).account.teams, account_settings(:account_settings_001).schedule_mail_email, start_date, end_date).deliver
    
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal ['info@fleetsuite.com'], email.from
    assert_equal '[FS_dev] FleetSuite - Team schedule', email.subject
  end
  
end
