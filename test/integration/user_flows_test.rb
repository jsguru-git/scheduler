require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest

  def setup
    https!
    host! "#{ accounts(:accounts_001).site_address }.#{ APP_CONFIG['env_config']['site_host'] }"
  end

  test 'Redirected to login screen when not logged in' do
    get_via_redirect "/"
    assert_response :success
    assert_equal "/session/new", path
  end

  test 'Redirected to dashboards#index when logged in' do
    create(:user, account_id: 1)
    post "/session", email: 'email1@example.com', password: 'example'
    assert_redirected_to '/'
  end

  test 'Redirect to session#new if failed login' do
    post "/session", email: 'notanemaiL@example.com', password: '12345'
    assert_equal '/session', path
  end
end
