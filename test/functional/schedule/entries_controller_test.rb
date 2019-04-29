require 'test_helper'

class Schedule::EntriesControllerTest < ActionController::TestCase
    

    def setup
        change_host_to(:accounts_001)
        login_as(:users_001)
        @permitted_read = [:account_holder, :administrator, :leader, :member]
        @permitted_report = [:account_holder, :administrator, :leader]
    end


    # index
    test "Show calendar" do 
        get :index
        assert_response :success
    end

    test '#index authorizes permitted' do
      @permitted_read.each do |role|
        login_as_role role
        get :index
        assert_response :success
      end
    end

    test '#index does not allow excluded' do
      (roles - @permitted_read).each do |role|
        login_as_role role
        get :index
        assert_redirected_to root_url
      end
    end

    test "get lead_time" do
        get :lead_time, nil, { :user_id => 1 }
        assert_not_nil assigns(:lead_time_users)
        assert_response :success
    end

    test '#lead_time authorizes permitted' do
      @permitted_report.each do |role|
        login_as_role role
        get :lead_time, nil, { :user_id => 1 }
        assert_response :success
      end
    end

    test '#lead_time does not allow excluded' do
      (roles - @permitted_report).each do |role|
        login_as_role role
        get :lead_time, nil, { :user_id => 1 }
        assert_redirected_to root_url
      end
    end
end
