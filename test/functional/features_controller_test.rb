require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase
    
    
    def setup
        change_host_to(:accounts_001)
        login_as(:users_001)
        @permitted_read = [:account_holder, :administrator, :leader]
        @permitted_write = [:account_holder]
    end
    
    # New
    test "should get new form" do
        get :new, :project_id => accounts(:accounts_001).projects.first.id
        assert :success
        assert_not_nil assigns(:feature)
        assert_not_nil assigns(:project)
    end
    
    test '#new authorizes permitted' do
        @permitted_write.each do |role|
          login_as_role role
          get :new, :project_id => accounts(:accounts_001).projects.first.id
          assert :success
        end
    end

    test '#new does not allow excluded' do
        (roles - @permitted_write).each do |role|
          login_as_role role
          get :new, :project_id => accounts(:accounts_001).projects.first.id
          assert_redirected_to root_url
        end
    end

    # Create
    test "should create new feature" do
        assert_difference 'Feature.all.size', +1 do
            post :create, :feature => {:name => 'Another feature'}, :project_id => accounts(:accounts_001).projects.first.id
        end
        assert_not_nil flash[:notice].to_s
        assert_response :redirect
    end

    test "should create new feature but fail" do
        assert_no_difference 'Feature.all.size' do
            post :create, :feature => {:name => ''}, :project_id => accounts(:accounts_001).projects.first.id
        end
        assert_response :success
    end

    test '#create authorizes permitted' do
        @permitted_write.each do |role|
          login_as_role role
          post :create, :feature => {:name => 'Another feature'}, :project_id => accounts(:accounts_001).projects.first.id
          assert_redirected_to project_tasks_path
        end
    end

    test '#create does not allow excluded' do
        (roles - @permitted_write).each do |role|
          login_as_role role
          post :create, :feature => {:name => 'Another feature'}, :project_id => accounts(:accounts_001).projects.first.id
          assert_redirected_to root_url
        end
    end

    # Cancel
    test "should cancel create" do
        get :cancel, :project_id => accounts(:accounts_001).projects.first.id
        assert_response :redirect
    end

    test '#cancel authorizes permitted' do
        @permitted_write.each do |role|
          login_as_role role
          get :cancel, :project_id => accounts(:accounts_001).projects.first.id
          assert_redirected_to project_tasks_path
        end
    end

    test '#cancel does not allow excluded' do
        (roles - @permitted_write).each do |role|
          login_as_role role
          get :cancel, :project_id => accounts(:accounts_001).projects.first.id
          assert_redirected_to root_url
        end
    end
    
    # Edit
    test "should get edit form" do
        get :edit, :project_id => features(:features_001).project.id, :id => features(:features_001).id
        assert :success
        assert_not_nil assigns(:feature)
        assert_not_nil assigns(:project)
    end

    test '#edit authorizes permitted' do
        @permitted_write.each do |role|
          login_as_role role
          get :edit, :project_id => features(:features_001).project.id, :id => features(:features_001).id
          assert_response :success
        end
    end

    test '#edit does not allow excluded' do
        (roles - @permitted_write).each do |role|
          login_as_role role
          get :edit, :project_id => features(:features_001).project.id, :id => features(:features_001).id
          assert_redirected_to root_url
        end
    end
    
    # Update
    test "should update feature" do
        assert_no_difference 'Feature.all.size' do
            put :update, :project_id => features(:features_001).project.id, :id => features(:features_001).id, :feature => { :name => 'new name' }
        end
        assert_not_nil flash[:notice].to_s
        assert_response :redirect
    end

    test "should update feature but fail" do
        assert_no_difference 'Feature.all.size' do
            put :update, :project_id => features(:features_001).project.id, :id => features(:features_001).id, :feature => { :name => '' }
        end
        assert_response :success
    end

    test '#update authorizes permitted' do
        @permitted_write.each do |role|
          login_as_role role
          put :update, :project_id => features(:features_001).project.id, :id => features(:features_001).id, :feature => { :name => 'new name' }
          assert_redirected_to project_tasks_path
        end
    end

    test '#update does not allow excluded' do
        (roles - @permitted_write).each do |role|
          login_as_role role
          put :update, :project_id => features(:features_001).project.id, :id => features(:features_001).id, :feature => { :name => '' }
          assert_redirected_to root_url
        end
    end
    
    # Destroy
    test "should remove feature" do
        assert_difference 'Feature.all.size', -1 do
            delete :destroy, :project_id => features(:features_001).project.id, :id => features(:features_001).id
        end
        assert_response :redirect
    end

    test '#destroy authorizes permitted' do
        @permitted_write.each do |role|
          login_as_role role
          delete :destroy, :project_id => features(:features_001).project.id, :id => features(:features_001).id
          assert_redirected_to project_tasks_path
        end
    end

    test '#destroy does not allow excluded' do
        (roles - @permitted_write).each do |role|
          login_as_role role
          delete :destroy, :project_id => features(:features_001).project.id, :id => features(:features_001).id
          assert_redirected_to root_url
        end
    end
end
