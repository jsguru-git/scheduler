require 'test_helper'

class Quote::QuoteSectionsControllerTest < ActionController::TestCase
  
  
  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted_read = [:account_holder, :administrator]
    @permitted_write = [:account_holder]
  end
  
  
  test "should update section" do
    put :update, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_sections(:quote_sections_006).id, :quote_section => {:content => 'a test'}
    
    assert_not_nil assigns(:quote_section)
    assert_equal 'a test', assigns(:quote_section).content
    assert_response :redirect
  end

  test '#update authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      put :update, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_sections(:quote_sections_006).id, :quote_section => {:content => 'a test'}
      assert_response :redirect
    end
  end

  test '#update does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      put :update, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_sections(:quote_sections_006).id, :quote_section => {:content => 'a test'}
      assert_redirected_to root_url
    end
  end
  
  
  test "should create new section" do
    assert_difference 'QuoteSection.count', +1 do
      post :create, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
    end
    
    assert_not_nil assigns(:quote_section)
    assert_response :redirect
  end

  test '#create authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      post :create, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
      assert_response :redirect
    end
  end

  test '#create does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      post :create, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002)
      assert_redirected_to root_url
    end
  end
  
  
  test "should remove section" do
    assert_difference 'QuoteSection.count', -1 do
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_sections(:quote_sections_006).id
    end
  end

  test '#destroy authorizes permitted' do
    @permitted_write.each do |role|
      login_as_role role
      assert_difference 'QuoteSection.count', -1 do
        delete :destroy, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_sections(:quote_sections_006).id
      end
    end
  end

  test '#destroy does not allow excluded' do
    (roles - @permitted_write).each do |role|
      login_as_role role
      delete :destroy, :project_id => quotes(:quotes_002).project_id, :quote_id => quotes(:quotes_002), :id => quote_sections(:quote_sections_006).id
      assert_redirected_to root_url
    end
  end
  
  
end
