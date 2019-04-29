require 'test_helper'

class SettingsControllerTest < ActionController::TestCase


  def setup
    set_ssl_request
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder]
  end


  test "should view update settings page" do
    get :index
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :index
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :index
      assert_redirected_to root_url
    end
  end

  test "should update settings" do
    put :update, :id => accounts(:accounts_001).id, :account_setting => {:working_day_end_time => '09:00:00', :working_day_end_time => '17:30:00'}
    assert_response :redirect
    assert_equal '30', assigns(:account_setting).working_day_end_time.strftime("%M")
  end


  test "should update settings but fail" do
    put :update, :id => accounts(:accounts_001).id, :account_setting => {:working_day_end_time => '09:00:00', :working_day_end_time => '08:30:00'}
    assert_response :success
    assert_equal false, assigns(:account_setting).valid?
  end

  test '#update authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :update, :id => accounts(:accounts_001).id, :account_setting => { :working_day_end_time => '09:00:00', :working_day_end_time => '08:30:00' }
      assert_response :success
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :update, :id => accounts(:accounts_001).id, :account_setting => { :working_day_end_time => '09:00:00', :working_day_end_time => '08:30:00' }
      assert_redirected_to root_url
    end
  end

  test "should view quote update settings page" do
    get :quote
    assert_response :success
  end

  test "should view schedule update settings page" do
    get :quote
    assert_response :success
  end

  test '#quote authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :quote
      assert_response :success
    end
  end

  test '#quote does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :quote
      assert_redirected_to root_url
    end
  end

  test '#update_quote authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :update_quote, :id => accounts(:accounts_001).id, :account_setting => {}
      assert_redirected_to quote_settings_path
    end
  end

  test '#update_quote does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :update_quote, :id => accounts(:accounts_001).id, :account_setting => {}
      assert_redirected_to root_url
    end
  end

  test '#schedule authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :schedule
      assert_response :success
    end
  end

  test '#schedule does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :schedule
      assert_redirected_to root_url
    end
  end

  test "should update schedule settings" do
    put :update_schedule, :id => accounts(:accounts_001).id, :account_setting => {:schedule_mail_frequency => 0}
    assert_response :redirect
    assert_equal 0, assigns(:account_setting).schedule_mail_frequency
  end

  test '#update_schedule authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :update_schedule, :id => accounts(:accounts_001).id, :account_setting => {:schedule_mail_frequency => 0}
      assert_redirected_to schedule_settings_path
    end
  end

  test '#update_schedule does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :update_schedule, :id => accounts(:accounts_001).id, :account_setting => {:schedule_mail_frequency => 0}
      assert_redirected_to root_url
    end
  end

  test '#invoice authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :invoice
      assert_response :success
    end
  end

  test '#invoice does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :invoice
      assert_redirected_to root_url
    end
  end

  test "should update invoice settings and allow for csv list of email addresses" do
    put :update_invoice, :id => accounts(:accounts_001).id, :account_setting => {:invoice_alert_email => 'scott@arthurly.com, stuart@arthurly.com'}
    assert_response :redirect
    assert_equal 'scott@arthurly.com, stuart@arthurly.com', assigns(:account_setting).invoice_alert_email
  end
  
  test "should update invoice settings and not allow invalid csv list of email addresses" do
    put :update_invoice, :id => accounts(:accounts_001).id, :account_setting => {:invoice_alert_email => 'scott@arthurly.com, stuartarthurly.com'}
    assert_response :success
    assert_equal false, assigns(:account_setting).valid?
  end

  test '#update_invoice authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :update_invoice, :id => accounts(:accounts_001).id, :account_setting => {:invoice_alert_email => 'scott@arthurly.com, stuartarthurly.com'}
      assert_response :success
    end
  end

  test '#update_invoice does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :update_invoice, :id => accounts(:accounts_001).id, :account_setting => {:invoice_alert_email => 'scott@arthurly.com, stuartarthurly.com'}
      assert_redirected_to root_url
    end
  end

  test "should get issue tracker details page" do
    get :issue_tracker
    assert_response :success
    assert_not_nil assigns(:account_setting)
  end

  test '#issue_tracker authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :issue_tracker
      assert_response :success
    end
  end

  test '#issue_tracker does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :issue_tracker
      assert_redirected_to root_url
    end
  end
  
  test "should submit issue tracker details" do
    put :update_issue_tracker, id: accounts(:accounts_001).id, account_setting: {issue_tracker_url: 'http://jira.com', issue_tracker_username: 'test', issue_tracker_password: 'test'}
    assert_response :redirect
    assert_not_nil assigns(:account_setting)
  end

  test '#update_issue_tracker authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      put :update_issue_tracker, id: accounts(:accounts_001).id, account_setting: {issue_tracker_url: 'http://jira.com', issue_tracker_username: 'test', issue_tracker_password: 'test'}
      assert_redirected_to issue_tracker_settings_path
    end
  end

  test '#update_issue_tracker does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      put :update_issue_tracker, id: accounts(:accounts_001).id, account_setting: {issue_tracker_url: 'http://jira.com', issue_tracker_username: 'test', issue_tracker_password: 'test'}
      assert_redirected_to root_url
    end
  end

  test '#remove_logo authorizes permitted' do
    request.env["HTTP_REFERER"] = account_settings_path
    @permitted.each do |role|
      login_as_role role
      get :remove_logo, id: accounts(:accounts_001).id
      assert_redirected_to account_settings_path
    end
  end

  test '#remove_logo does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :remove_logo, id: accounts(:accounts_001).id
      assert_redirected_to root_url
    end
  end

  test '#personal authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :personal
      assert_response :success
    end
  end

  test '#personal does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :personal
      assert_redirected_to root_url
    end
  end

  test '#inform_overdue_timesheet authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :inform_overdue_timesheet
      assert_redirected_to settings_path
    end
  end

  test '#inform_overdue_timesheet does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :inform_overdue_timesheet
      assert_redirected_to root_url
    end
  end

end
