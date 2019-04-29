require 'test_helper'

class TrackApi::TimingsControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader, :member]
  end

  test "should get timings for a given user" do
    get :index, :user_id => users(:users_001).id, :start_date => '2012-05-09', :end_date => '2012-05-11', :format => 'json'
    assert_not_nil assigns(:timings)
    assert_response :success
  end

  test "should get timings for a given team" do
    get :index, :team_id => teams(:teams_001).id, :start_date => '2012-05-09', :end_date => '2012-05-11', :format => 'json'
    assert_not_nil assigns(:timings)
    assert_response :success
  end

  test "should get timings for a given user but fail as not an admin and not getting own user" do
    login_as(:users_008)
    get :index, :user_id => users(:users_001).id, :start_date => '2012-05-09', :end_date => '2012-05-11', :format => 'json'
    assert_response :redirect
  end

  test "should get timings for own user when not an admin" do
    login_as(:users_008)
    get :index, :user_id => users(:users_008).id, :start_date => '2012-05-09', :end_date => '2012-05-11', :format => 'json'
    assert_not_nil assigns(:timings)
    assert_response :redirect
  end

  test "should get timings for a given team but fail as not a admin" do
    login_as(:users_008)
    get :index, :team_id => teams(:teams_001).id, :start_date => '2012-05-09', :end_date => '2012-05-11', :format => 'json'
    assert_response :redirect
  end

  test '#index authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :index, user_id: users(:users_001).id, start_date: '2012-05-09', end_date: '2012-05-11', format: :json
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :index, user_id: users(:users_001).id, start_date: '2012-05-09', end_date: '2012-05-11', format: :json
      assert_redirected_to root_url
    end
  end
    

  test "should create timing as an admin" do
    assert_difference 'Timing.all.size', +1 do
      post :create, :user_id => users(:users_008).id, :format => 'json', :timing => {:started_at => '2012-07-09 10:00:00', :ended_at => '2012-07-09 10:59:00', :project_id => tasks(:tasks_001).project_id, :task_id => tasks(:tasks_001).id}
    end
  end

  test "should create timing for myself as a normal user but fail as an entry on that day has been submitted" do
    login_as(:users_008)
    
    timings(:four).submitted = true
    timings(:four).save
    
    assert_no_difference 'Timing.all.size' do
      post :create, :user_id => users(:users_008).id, :format => 'json', :timing => {:started_at => '2012-07-11 10:00:00', :ended_at => '2012-07-11 10:59:00', :project_id => tasks(:tasks_001).project_id, :task_id => tasks(:tasks_001).id}
      assert_response :redirect
    end
  end

  test "should create timing for someone else as a normal user and fail" do
    login_as(:users_008)
    assert_no_difference 'Timing.all.size' do
      post :create, :user_id => users(:users_001).id, :format => 'json', :timing => {:started_at => '2012-07-09 10:00:00', :ended_at => '2012-07-09 10:59:00', :project_id => tasks(:tasks_001).project_id, :task_id => tasks(:tasks_001).id}
    end
  end

  test "should create timing as an admin but fail validaiton" do
    assert_no_difference 'Timing.all.size' do
      post :create, :user_id => users(:users_008).id, :format => 'json', :timing => {:started_at => '2012-07-09 10:00:00', :ended_at => '', :project_id => tasks(:tasks_001).project_id, :task_id => tasks(:tasks_001).id}
      assert assigns(:timing).errors[:ended_at].present?
      assert_response :unprocessable_entity
    end
  end    

  test "should update timing as an admin" do
    assert_no_difference 'Timing.all.size' do
      put :update, :id => timings(:three).id, :user_id => users(:users_008).id, :format => 'json', :timing => {:ended_at => '2012-07-11 10:59:00'}
      assert_equal DateTime.parse('2012-07-11 10:59:00'), assigns(:timing).ended_at
    end
  end

  test "should update timing for myself as a normal user but fail as an entry on that day has been submitted" do
    login_as(:users_008)
    
    timings(:four).submitted = true
    timings(:four).save
    
    assert_no_difference 'Timing.all.size' do
      put :update, :id => timings(:three).id, :user_id => users(:users_008).id, :format => 'json', :timing => {:ended_at => '2012-07-11 12:59:00'}
      assert_response :redirect
    end
  end

  test "should update timing for myself as a normal user but fail as its been submitted" do
    login_as(:users_008)
    
    timings(:three).submitted = true
    timings(:three).save
    
    assert_no_difference 'Timing.all.size' do
      put :update, :id => timings(:three).id, :user_id => users(:users_008).id, :format => 'json', :timing => {:ended_at => '2012-07-11 10:59:00'}
      assert_response :redirect
    end
  end

  test "should update timing for someone else as a normal user and fail" do
    login_as(:users_008)
    assert_no_difference 'Timing.all.size' do
      put :update, :id => timings(:one).id, :user_id => users(:users_001).id, :format => 'json', :timing => {:ended_at => '2012-05-10 09:59:00'}
      timings(:one).reload
      assert_not_equal DateTime.parse('2012-05-10 09:59:00'), timings(:one).ended_at
    end
  end

  test "should update timing as an admin but fail validaiton" do
    put :update, :id => timings(:three).id, :user_id => users(:users_008).id, :format => 'json', :timing => {:ended_at => '2012-07-11 01:59:00'}
    assert assigns(:timing).errors[:started_at].present?
    assert_response :unprocessable_entity
  end

  test "should destroy timing as an admin" do
    assert_difference 'Timing.all.size', -1 do
      delete :destroy, :id => timings(:three).id, :user_id => users(:users_008).id, :format => 'json'
    end
  end    

end
