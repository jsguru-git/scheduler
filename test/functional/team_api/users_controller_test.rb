require 'test_helper'

class TeamApi::UsersControllerTest < ActionController::TestCase

  def setup
    change_host_to(:accounts_001)
    login_as(:users_001)
    @request.env['HTTPS'] = 'on'
    @permitted_read = [:account_holder, :administrator, :leader, :member]
  end

  test '#show authorizes permitted' do
    @permitted_read.each do |role|
      login_as_role role
      get :show, id: 1, format: :json
      assert_response :success
    end
  end

  test '#show does not allow excluded' do
    (roles - @permitted_read).each do |role|
      login_as_role role
      get :show, id: 1, format: :json
      assert_redirected_to root_url
    end
  end

end