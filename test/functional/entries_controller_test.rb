require 'test_helper'

class EntriesControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @permitted = [:account_holder, :administrator, :leader, :member]
  end

  test '#index should exlusively respond to ics format' do
    get :index, format: :ics
    assert_response :success
  end

  test '#index should not respond to html' do
    get :index, format: :html
    assert_response :not_acceptable
  end

  test '#index authorizes permitted' do
    @permitted.each do |role|
      login_as_role role
      get :index, format: :ics
      assert_response :success
    end
  end

  test '#index does not allow excluded' do
    (roles - @permitted).each do |role|
      login_as_role role
      get :index, format: :ics
      assert_redirected_to root_url
    end
  end

end