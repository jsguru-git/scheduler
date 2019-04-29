require 'test_helper'

class QuoteDefaultSectionsControllerTest < ActionController::TestCase
  
  def setup
    set_ssl_request
    change_host_to(:accounts_001)
    login_as(:users_001)
  end
  
  test "should update section" do
    put :update, id: quote_default_sections(:one).id, quote_default_section: {:content => 'a test'}
    
    assert_not_nil assigns(:quote_default_section)
    assert_equal 'a test', assigns(:quote_default_section).content
    assert_response :redirect
  end
  
  test "should create new section" do
    assert_difference 'QuoteDefaultSection.count', +1 do
      post :create
    end
    
    assert_not_nil assigns(:quote_default_section)
    assert_response :redirect
  end  
  
  test "should remove section" do
    assert_difference 'QuoteDefaultSection.count', -1 do
      delete :destroy, id: quote_default_sections(:one).id
    end
  end
  
  
end