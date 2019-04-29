require 'test_helper'

class Quote::QuoteActivitiesControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator]
    @permitted_write = [:account_holder]
  end
  
  
  test "should show new activity form" do
    get :new, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
    
    assert_not_nil assigns(:quote_activity)
    assert_response :success
  end

  test '#new authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :new, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
      assert_response :success
    end
  end

  test '#new does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :new, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
      assert_redirected_to root_url
    end
  end
  
  
  test "should create new activity" do
    assert_difference 'QuoteActivity.count', +1 do
      post :create, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :quote_activity => {:discount_percentage => 0.00, :estimate_type => 1, :name => 'new', :rate_card_id => rate_cards(:rate_cards_001).id}
    end
    
    assert_not_nil assigns(:quote_activity)
    assert_response :redirect
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
      assert_response :success
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
      assert_redirected_to root_url
    end
  end
  
  
  test "should show edit activity form" do
    get :edit, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id
    
    assert_not_nil assigns(:quote_activity)
    assert_response :success
  end

  test '#edit authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      get :edit, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id
      assert_response :success
    end
  end

  test '#edit does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      get :edit, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id
      assert_redirected_to root_url
    end
  end
  
  
  test "should update activity" do
    put :update, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id, :quote_activity => {:name => 'new'}
    
    assert_not_nil assigns(:quote_activity)
    assert_equal 'new',assigns(:quote_activity).name
    assert_response :redirect
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id, :quote_activity => {:name => 'new'}
      assert_response :redirect
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id, :quote_activity => {:name => 'new'}
      assert_redirected_to root_url
    end
  end
  
  
  test "should remove activity" do
    assert_difference 'QuoteActivity.count', -1 do
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id
    end
    assert_response :redirect
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id
      assert_response :redirect
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_activities(:quote_activities_004).id
      assert_redirected_to root_url
    end
  end
      
  
end
