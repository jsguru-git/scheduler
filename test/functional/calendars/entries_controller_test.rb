require 'test_helper'

class Calendars::EntriesControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader, :member]
    @permitted_write = [:account_holder, :administrator]
    @permitted_report = [:account_holder, :administrator, :leader]
  end

  test "post to create" do
    assert_difference 'Entry.all.length', +1 do
      post :create, :format => 'json', :entry => { :project_name => accounts(:accounts_001).projects.first.name, :user_id => accounts(:accounts_001).users.first.id, :start_date => Date.today, :end_date => Date.today + 1 }
      assert_response :created
    end
	end

	test "post to create with no project name or project id" do
	  assert_no_difference 'Entry.all.length' do
      post :create, :format => 'json', :entry => {:user_id => accounts(:accounts_001).users.first.id, :start_date => Time.now.to_date}
			assert_response 422
		end
	end

  test "post to create with new project name" do
		assert_difference 'Entry.all.length', +1 do
	    assert_difference 'Project.all.length', +1 do
          post :create, :format => 'json', :entry => {:user_id => accounts(:accounts_001).users.first.id, :start_date => Time.now.to_date, :project_name => 'new unique name' }
    			assert_not_nil assigns(:entries).first.project_id
    			assert_response :created
      end
    end
  end

  test "post to create with new project name but name already exists" do
    assert_difference 'Entry.all.length', +1 do
      assert_no_difference 'Project.all.length' do
        post :create, :format => 'json', :entry => {:user_id => accounts(:accounts_001).users.first.id, :start_date => Time.now.to_date, :project_name => 'Project 1' }
        assert_not_nil assigns(:entries).first.project_id
        assert_response :created
      end
    end
	end
   
  test "post to create and fail" do
    assert_no_difference 'Entry.all.length' do
      post :create, :format => 'json', :entry => {:project_id => accounts(:accounts_001).projects.first.id, :user_id => accounts(:accounts_001).users.first.id, :end_date => Time.now.to_date}
      assert_response 422
    end
	end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'Entry.all.length', +1 do
        assert_no_difference 'Project.all.length' do
          post :create, :format => 'json', :entry => {:user_id => accounts(:accounts_001).users.first.id, :start_date => Time.now.to_date, :project_name => 'Project 1' }
          assert_not_nil assigns(:entries).first.project_id
          assert_response :created
        end
      end
      assert_response :success
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :format => 'json', :entry => {:user_id => accounts(:accounts_001).users.first.id, :start_date => Time.now.to_date, :project_name => 'Project 1' }
      assert_redirected_to root_url
    end
  end
    
  # index
	test "Get entries json" do 
		get :index, :format => 'json'
		assert_not_nil assigns(:entries)
		assert_not_nil assigns(:cal)
		assert_response :success
	end
	
	# index
	test "Get entries for projects json" do 
		get :index, :format => 'json', :project_id => accounts(:accounts_001).projects.first.id
		assert_not_nil assigns(:entries)
		assert_not_nil assigns(:cal)
		assert_response :success
	end
	
	#
	# index with custom start_date
	test "Get entries json with start date" do 
		get :index, :format => 'json', :start_date => '2012-05-29'
		assert_not_nil assigns(:entries)
		assert_not_nil assigns(:cal)
		assert_response :success
	end
	
	#
	# index with custom start_date
	test "Get entries json with start date and end date" do 
		get :index, :format => 'json', :start_date => '2012-05-29', :end_date => '2012-06-10'
		assert_not_nil assigns(:entries)
		assert_not_nil assigns(:cal)
		assert_response :success
	end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :format => 'json', :start_date => '2012-05-29', :end_date => '2012-06-10'
      assert_not_nil assigns(:entries)
      assert_not_nil assigns(:cal)
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :format => 'json', :start_date => '2012-05-29', :end_date => '2012-06-10'
      assert_redirected_to root_url
    end
  end
    
	
	# Update
  test "should update existing entry" do
    assert_no_difference 'Entry.all.length' do
      put :update, :format => 'json', :entry => {:end_date => accounts(:accounts_001).entries.first.end_date + 2.days}, :id => accounts(:accounts_001).entries.first.id
			assert_response :no_content
    end
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_no_difference 'Entry.all.length' do
        put :update, :format => 'json', :entry => {:end_date => accounts(:accounts_001).entries.first.end_date + 2.days}, :id => accounts(:accounts_001).entries.first.id
        assert_response :no_content
      end
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :format => 'json', :entry => {:end_date => accounts(:accounts_001).entries.first.end_date + 2.days}, :id => accounts(:accounts_001).entries.first.id
      assert_redirected_to root_url
    end
  end
    
  test "should get entries_for_user" do
    get :entries_for_user, :format => 'json'
    assert_response :success
  end

  test '#entries_for_user authorizes permitted' do
    @permitted_report.each do |role|
      login_as_role role
      get :entries_for_user, :format => 'json'
      assert_response :success
    end
  end

  test '#entries_for_user not allow excluded' do
    (roles - @permitted_report).each do |role|
      login_as_role role
      get :entries_for_user, :format => 'json'
      assert_redirected_to root_url
    end
  end

	# Update
	test "should update existing entry but fail validation" do
    assert_no_difference 'Entry.all.length' do
      put :update, :format => 'json', :entry => {:start_date => nil}, :id => accounts(:accounts_001).entries.first.id
		  assert_response 422
		end
  end

  # Destroy
  test "should delete entry" do
    assert_difference 'Entry.all.length', -1 do
      delete :destroy, :format => 'json', :id => accounts(:accounts_001).entries.first.id
      assert_response :no_content
    end
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'Entry.all.length', -1 do
        delete :destroy, :format => 'json', :id => accounts(:accounts_001).entries.first.id
      end
      assert_response :success
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :format => 'json', :id => accounts(:accounts_001).entries.first.id
      assert_redirected_to root_url
    end
  end
    
    
	# Destroy
  test "should delete entry from different account but fail" do
    assert_raise ActiveRecord::RecordNotFound do
      delete :destroy, :format => 'json', :id => accounts(:accounts_002).entries.first.id
    end
  end  
end
