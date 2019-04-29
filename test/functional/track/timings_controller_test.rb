require 'test_helper'

class Track::TimingsControllerTest < ActionController::TestCase
    
    
    #
    #
    def setup
        change_host_to(:accounts_001)
        login_as(:users_001)
        @permitted = [:account_holder, :administrator, :leader, :member]
    end
    
    
    #
    #
    test "should get timesheet as admin user" do
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
    
    #
    #
    test "should submit time entries for a given day" do
        post :submit_time, :user_id => timings(:one).user_id, :date => timings(:one).started_at.to_date
        timings(:one).reload
        assert timings(:one).submitted?
    end

    test "should submit time entries for a given day as a normal user but for a different user" do
        login_as(:users_008)
        assert_raise ActiveRecord::RecordNotFound do
            post :submit_time, :user_id => timings(:one).user_id, :date => timings(:one).started_at.to_date
        end
    end

    test '#submit_time authorizes permitted' do
      Calendar.any_instance.stubs(:start_date).returns(timings(:one).started_at.to_date)
      @permitted.each do |role|
        login_as_role role
        post :submit_time, :user_id => @request.session[:user_id], :date => timings(:one).started_at.to_date
        assert_redirected_to track_timings_path(:user_id => @request.session[:user_id], :start_date => timings(:one).started_at.to_date)
      end
    end

    test '#submit_time does not allow excluded' do
      (roles - @permitted).each do |role|
        login_as_role role
        post :submit_time, :user_id => timings(:one).user_id, :date => timings(:one).started_at.to_date
        assert_redirected_to root_url
      end
    end

    test '#submitted_time_report authorizes permitted' do
      @permitted.each do |role|
        login_as_role role
        get :submitted_time_report, :user_id => users(:users_008).id
        assert_response :success
      end
    end

    test '#submitted_time_report does not allow excluded' do
      (roles - @permitted).each do |role|
        login_as_role role
        get :submitted_time_report, :user_id => users(:users_008).id
        assert_redirected_to root_url
      end
    end
    
    test '#shift_calendar authorizes permitted' do
      @permitted.each do |role|
        login_as_role role
        get :shift_calendar, { direction: :forward, :user_id => timings(:one).user_id, :start_date => timings(:one).started_at.to_date, shift_days: 1 }
        assert_redirected_to track_timings_path(:user_id => timings(:one).user_id, :start_date => timings(:one).started_at.to_date + 1.day)
      end
    end

    test '#shift_calendar does not allow excluded' do
      (roles - @permitted).each do |role|
        login_as_role role
        get :shift_calendar, { direction: :forward, :user_id => timings(:one).user_id, :start_date => timings(:one).started_at.to_date, shift_days: 1 }
        assert_redirected_to root_url
      end
    end
    
end
