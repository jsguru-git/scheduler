require 'test_helper'

class Quote::QuotesControllerTest < ActionController::TestCase

  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator, :leader]
    @permitted_write = [:account_holder]
  end
  
  
  test "should list quotes for a given project" do
    get :index, :project_id => quotes(:quotes_002).project_id
    
    assert_not_nil assigns(:quotes)
    assert_response :success
  end

  test '#index authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :index, :project_id => quotes(:quotes_002).project_id
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :index, :project_id => quotes(:quotes_002).project_id
      assert_redirected_to root_url
    end
  end
  
  
  test "should create a new quote" do
    assert_difference 'Quote.count', +1 do
      post :create, :project_id => quotes(:quotes_002).project_id
    end
    
    assert_not_nil assigns(:quote)
    assert_response :redirect
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'Quote.count', +1 do
        post :create, :project_id => quotes(:quotes_002).project_id
      end
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :project_id => quotes(:quotes_002).project_id
      assert_redirected_to root_url
    end
  end
  
  
  test "should set defaults when creating a new quote" do
    post :create, :project_id => quotes(:quotes_002).project_id
    
    assert_not_nil assigns(:quote)
    assert_equal 0, assigns(:quote).quote_status
    assert_equal 20.0, assigns(:quote).vat_rate
    assert_equal true, assigns(:quote).new_quote
  end
  
  
  test "should create default sections when creating a new quote" do
    assert_difference 'QuoteSection.count', +3 do
      post :create, :project_id => quotes(:quotes_002).project_id
    end
    assert_not_nil assigns(:quote).quote_sections
  end
  
  
  test "should update a quote" do
    put :update, :project_id => quotes(:quotes_003).project_id, :id => quotes(:quotes_003).id, :quote => {:title => 'A quote'}
    
    assert_not_nil assigns(:quote)
    assert_equal 'A quote', assigns(:quote).title
    assert_response :redirect
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, :project_id => quotes(:quotes_003).project_id, :id => quotes(:quotes_003).id, :quote => {:title => 'A quote'}
      assert_response :redirect
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :project_id => quotes(:quotes_003).project_id, :id => quotes(:quotes_003).id, :quote => {:title => 'A quote'}
      assert_redirected_to root_url
    end
  end
  
  
  test "should show a read only quote" do
    get :show, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id
    
    assert_not_nil assigns(:quote)
    assert_response :success
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :show, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :show, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id
      assert_redirected_to root_url
    end
  end
  
  
  test "should show a editable quote" do
    get :show, :project_id => quotes(:quotes_001).project_id, :id => quotes(:quotes_001).id
    
    assert_not_nil assigns(:quote)
    assert_response :success
  end
  
  
  test "should show edit po details" do
    put :edit_details, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id, :field => 'po_number'
    
    assert_not_nil assigns(:quote)
    assert_response :success
  end

  test '#edit_details authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :edit_details, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id, :field => 'po_number'
      assert_response :success
    end
  end

  test '#edit_details does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :edit_details, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id, :field => 'po_number'
      assert_redirected_to root_url
    end
  end
  
  
  test "should show edit extra costs" do
    put :edit_details, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id, :field => 'extra_costs'
    
    assert_not_nil assigns(:quote)
    assert_response :success
  end
  
  
  test "should update po details" do
    put :update_details, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id, :field => 'po_number', :quote => {:po_number => 'A'}
    
    assert_equal 'A', assigns(:quote).po_number
    assert_response :redirect
  end

  test '#update_details authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update_details, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id, :field => 'po_number', :quote => {:po_number => 'A'}
      assert_response :redirect
    end
  end

  test '#update_details does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update_details, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id, :field => 'po_number', :quote => {:po_number => 'A'}
      assert_redirected_to root_url
    end
  end
  
  
  test "should copy activities from previous quote" do
    old_activity_count = quotes(:quotes_002).quote_activities.length
    put :copy_from_previous, :project_id => quotes(:quotes_001).project_id, :id => quotes(:quotes_002).id
    
    assert_equal 2, assigns(:copied)
    assert_not_equal old_activity_count, assigns(:quote).quote_activities.length
  end

  test '#copy_from_previous authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :copy_from_previous, :project_id => quotes(:quotes_001).project_id, :id => quotes(:quotes_002).id
      assert_equal 2, assigns(:copied)
    end
  end

  test '#copy_from_previous does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :copy_from_previous, :project_id => quotes(:quotes_001).project_id, :id => quotes(:quotes_002).id
      assert_redirected_to root_url
    end
  end
  
  test "should delete a quote" do
    assert_difference 'Quote.count', -1 do
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id
    end

    assert_response :redirect
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'Quote.count', -1 do
        delete :destroy, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id
      end
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id
      assert_redirected_to root_url
    end
  end
  
  
  test "should delete a quote but fail as its not the latest version" do
    assert_no_difference 'Quote.count' do
      delete :destroy, :project_id => quotes(:quotes_001).project_id, :id => quotes(:quotes_001).id
    end

    assert_response :redirect
  end
  
  
  test "should delete a quote but fail as they are not an admin or the orgiional creator" do
    login_as(:users_008)
    
    assert_no_difference 'Quote.count' do
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :id => quotes(:quotes_002).id
    end

    assert_response :redirect
  end
  
  
end
