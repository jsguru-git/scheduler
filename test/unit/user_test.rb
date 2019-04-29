#coding: utf-8

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:users_001)
  end

  valid_params = { firstname: "Walter",
                   lastname: "White",
                   password: "bluecrystal" }

  test "creating a valid user does not raise exception" do
    assert_nothing_raised do
      User.create!(valid_params.merge(email: "walt@yahoo.com"))
    end
    assert_equal User.last.email, "walt@yahoo.com"
  end

  test "a new user is assigned an API key" do
    user = User.create!(valid_params.merge(email: "walt@bluecrystal.com"))
    assert user.api_key.present?
  end

  test "a user can reset their API key if required" do
    user = User.create!(valid_params.merge(email: "walt@mysite.com"))
    first_key = user.access_token
    user.reset_token!
    assert user.api_key.present?
    second_key = user.access_token
    assert_not_equal first_key, second_key
  end

  test "can find a user by API key" do
    user = User.create!(valid_params.merge(email: "blue@crystal.com"))
    found = User.find_by_api_token(user.access_token)
    assert_equal found.id, user.id
  end

  test "first name is present" do
    @user.firstname = nil
    assert_equal @user.valid?, false
  end

  test "first name is less than 255 characters" do
    @user.firstname = 256.times.collect { "a" }.join
    assert_equal @user.valid?, false
  end

  test "lastname is present" do
    @user.lastname = nil
    assert_equal @user.valid?, false
  end

  test "lastname is less than 255 characters" do
    @user.lastname = 256.times.collect { "a" }.join
    assert_equal @user.valid?, false
  end

  test "email is present" do
    @user.email = nil
    assert_equal @user.valid?, false
  end

  test "email is less than 255 characters" do
    @user.email = 256.times.collect { "a" }.join
    assert_equal @user.valid?, false
  end

  test "email must contain an @" do
    @user.email = "noat.com"
    assert_equal @user.valid?, false
  end

  test "email must contain a domain" do
    @user.email = "no@nodomain"
    assert_equal @user.valid?, false
  end

  test "email is unique" do
    joe = users(:users_001)
    joe.save
    bob = users(:users_005)
    bob.email = users(:users_001).email
    assert_equal bob.valid?, false
  end

  test "pass is more than 6 characters" do
    joe = users(:users_001)
    joe.password = "123"
    assert_equal joe.valid?, false
    joe.password = "123456"
    assert_equal joe.valid?, true
  end

  test "name returns firstname and lastname" do
    joe = users(:users_001)
    assert_equal joe.name, "Test User"
  end

  # account_holder_for_account
  test "finds the user who holds an account" do
    assert_equal User.account_holder_for_account(accounts(:accounts_001)), users(:users_001)
  end

  # is_account_holder?
  test "user is an account holder" do
    assert_equal users(:users_001).is_account_holder?, true
    assert_equal users(:users_005).is_account_holder?, false
  end

  # is_administrator?
  test "user is an administrator" do
    assert_equal users(:users_001).is_administrator?, false
    assert_equal users(:users_007).is_administrator?, true
  end

  # is_account_holder_or_administrator
  test "is_account_holder_or_administrator" do
    assert_equal users(:users_001).is_account_holder_or_administrator?, true
    assert_equal users(:users_005).is_account_holder_or_administrator?, false
  end

  # set_last_login
  test "set the last login date" do
    users(:users_001).set_last_login
    assert_kind_of ActiveSupport::TimeWithZone, users(:users_001).last_login_at
  end

  # make_account_holder
  test "make a user an account holder" do
    users(:users_005).make_account_holder
    assert_equal users(:users_005).is_account_holder?, true
  end

  # make_reset_code
  test "creates a reset code" do
    users(:users_001).make_reset_code
    assert_not_nil users(:users_001).password_reset_code
  end

  test "clear_reset_code" do
    users(:users_001).make_reset_code
    users(:users_001).clear_reset_code
    assert_nil users(:users_001).password_reset_code
  end

  test "should search for user" do
    search_vars = {:firstname => 'tes'}
    users = User.search_users(accounts(:accounts_001), search_vars)
    assert_not_nil users

    search_vars = {:firstname => 'test'}
    users = User.search_users(accounts(:accounts_001), search_vars)
    assert_not_nil users

    search_vars = {:firstname => 'testasdfasfsadfds'}
    users = User.search_users(accounts(:accounts_001), search_vars)
    assert_equal 0, users.length
  end

  test "name_truncated should return first name and last letter" do
    user = users(:users_002)
    assert_equal "Jon J",  user.name_truncated
  end

  test "name_truncated should not fail if last_name is nil" do
    user = users(:users_002)
    user.stubs(:lastname).returns(nil)
    assert_equal "Jon", user.name_truncated
  end

  test "should find projects scheduled for user" do
    user = users(:users_002)
    assert user.scheduled_projects(Date.today, Date.today + 1.week).empty?
  end

  test '#scheduled_projects_ics should return list of scheduled items as ICS' do
    user = users(:users_008)
    Delorean.time_travel_to('17th May 2012') do
      assert_equal Icalendar::Calendar, user.scheduled_projects_ics.class
    end
  end

  # Account component method

  test "should have account component method" do
    user = users(:users_001)
    assert user.respond_to?(:has_component?)
  end

  test "should return true when component present" do
    user = users(:users_001)
    assert_equal user.has_component?(1), true
  end

  test "should return false when component absent" do
    user = users(:users_001)
    assert_equal user.has_component?(100), false
  end

  test "projects tracked by a user should return empty array when none present" do
    user = users(:users_001)
    timings = Timing.for_period_of_time(user.id, 1.month.ago, Time.now)
    assert timings.empty?
    assert user.projects_tracked.empty?
  end

  test "projects tracked by a user should return project ids when present" do
    user = users(:users_001)
    user.timings.create!(:project_id => 2,
                         :task_id => 1,
                         :started_at => DateTime.now - 60.minutes,
                         :ended_at => DateTime.now)

    assert user.projects_tracked.include?(2)
  end

  test "days worked should return a hash of days worked" do
    assert @user.days_worked.kind_of?(Hash)
  end

  test "days worked returns the days worked for a user" do
    expected = {:sunday => false,
                :monday => true,
                :tuesday => true,
                :wednesday => true,
                :thursday => true,
                :friday => true,
                :saturday => false}
    assert_equal expected, @user.days_worked
  end

  test "potential_working_days returns all weekdays in the month" do
    start_date = Date.parse("2013-05-01")
    end_date = start_date.end_of_month
    week_days = (start_date..end_date).select {|d| (1..5).include?(d.wday) }.size
    assert_equal @user.potential_working_days(start_date, end_date), week_days
  end

  test "works_on? returns boolean" do
    assert @user.works_on?(:wednesday)
    assert !@user.works_on?(:sunday)
  end

  test "capacity returns the users capacity" do
    start = Date.today.beginning_of_month
    end_date = start.end_of_month
    assert_equal @user.capacity(start, end_date), 0
  end

  test "check if user limit reached" do
    assert_equal false, User.will_exceed_plan_limit_if_additional_added?(accounts(:accounts_001), 1)
    assert_equal true, User.will_exceed_plan_limit_if_additional_added?(accounts(:accounts_001), 100)
  end

  test "should send limit reached email" do
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      users(:users_001).send_reached_plan_limit_email
      users(:users_001).send_reached_plan_limit_email # should only send once
    end
  end

  test ".update_administrators correctly updates administrator roles" do
    user1 = users(:users_007)
    user2 = users(:users_008)
    assert !User.find(user2.id).is_administrator?
    User.update_administrators(user1.account, [user2.id], user1)
    assert User.find(user2.id).is_administrator?
  end

  test '#billable_amount_cents should return the billable amount for a user' do
    user = users(:users_008)
    Delorean.time_travel_to('2012-07-30') do
      assert_equal 9514.0, user.billable_amount_cents
    end
  end

  test '#utilisation returns the percentage of billable hours against total hours worked' do
    user = users(:users_008)
    Delorean.time_travel_to('2012-07-30') do
      timing = user.timings.new(started_at: 2.hours.ago, ended_at: 1.hour.ago, task_id: 1)
      timing.duration_minutes = 60
      timing.task.count_towards_time_worked = false
      assert_equal 100.0, user.utilisation
    end
  end

  test '#days_without_time_tracked should return an Array of dates in the last week that have not been tracked against excl. working days' do
    Delorean.time_travel_to('last monday') do
      user = users(:users_007)
      dates = (1.week.ago.to_date..Date.today - 1).map(&:to_date).reject{ |d| d.saturday? || d.sunday? }
      assert_equal dates, user.days_without_time_tracked
    end
  end

  test '#days_without_time_tracked should return an Array of dates excluding ones that have something tracked' do
    Delorean.time_travel_to('13th May 2012') do
      user = users(:users_001)
      Timing.submit_entries_for_user_and_day(user.id, '2012-05-10'.to_date)
      non_working_days = user.account.account_setting.working_days.keep_if { |_, v| v.to_i.zero? }.keys.map(&:to_s).map(&:capitalize)
      dates = (1.week.ago.to_date..Date.today - 1).map(&:to_date).reject{ |d| non_working_days.include?(d.strftime('%A')) }
      dates.delete_at(3)
      assert_equal dates, user.days_without_time_tracked
    end
  end

  test '#days_without_time_tracked should only look as far back as look_back' do
    user = users(:users_007)
    dates = dates = (3.days.ago.to_date..Date.today - 1).map(&:to_date).reject{ |d| d.saturday? || d.sunday? }
    assert_equal dates, user.days_without_time_tracked(3.days)
  end

  test '#days_without_time_tracked should return an empty Array for archived employees' do
    user = users(:users_007)
    user.archived = true
    user.save!
    assert_equal [], user.days_without_time_tracked
  end

  test '#days_without_time_tracked should throw an except if a time less than 1 day is entered as look_back' do
    user = users(:users_007)
    invalid_dates = [1.hour, 1.minute, 23.hours, 25.minutes]
    invalid_dates.each do |invalid_date|
      assert_raises ArgumentError do
        user.days_without_time_tracked(invalid_date)
      end
    end
  end

  test '#check_account_holder_exists should add an ActiveRecord error if the user is the last account_holder and the role is changed' do
    user = users(:users_001)
    user.roles = [Role.find_by_title('member')]

    assert_difference 'user.errors.count', +1 do
      user.save
    end
  end

  test '#biography should return raw markdown if passed false' do
    user = users(:users_001)
    assert_equal 'My name is **Scott**', user.biography(false)
  end

  test '#biography should return raw markdown if passed nothing' do
    user = users(:users_001)
    assert_equal 'My name is **Scott**', user.biography
  end

  test '#biography should return HTML if passed true' do
    user = users(:users_001)
    assert_equal '<p>My name is <strong>Scott</strong></p>', user.biography(true).strip
  end

  test '#biography should return empty string if the user biography is nil (parsed)' do
    user = users(:users_002)
    assert_equal '', user.biography(true)
  end

  test '#biography should return empty string if the user biography is nil (raw HTML)' do
    user = users(:users_002)
    assert_equal '', user.biography(false)
  end

  test '#parsed_biography should return HTML' do
    user = users(:users_001)
    assert_equal '<p>My name is <strong>Scott</strong></p>', user.parsed_biography.strip
  end

end

