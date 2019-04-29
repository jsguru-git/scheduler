require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)


require 'rails/test_help'
require 'unit/policies/policy_test'
require 'delorean'
include FactoryGirl::Syntax::Methods

class ActiveSupport::TestCase

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # def login
  #     @request.host = "#{accounts(:basic).site_address}." + APP_CONFIG['env_config']['site_host']
  #     Account.stubs(:find_active_account).returns(accounts(:basic))
  # end

  #
  # AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    @request.session[:user_id] = user ? (user.is_a?(User) ? user.id : users(user).id) : nil
  end

  def login_as_role(role)
    user_role = build(:role, role)
    User.any_instance.stubs(:roles).returns([user_role])
    User.any_instance.stubs(:account_id).returns(1)
    login_as(:users_001)
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'testtt') : nil
  end

  # Authenticaiton for admin pannel
  def authorize_as_profile_admin
    @request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials('arthurly', 'arthurly1010account')
  end

  # Add more helper methods to be used by all tests here...
  def change_host_to(site)
    @request.host = accounts(site).site_address + ".localhost.com"
  end

  def set_ssl_request
    @request.env['HTTPS'] = 'on'
  end

  def unset_ssl_request
    @request.env['HTTPS'] = 'off'
  end

  # HTTP basic login for testing API calls
  def basic_login(email, password)
    @request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials(email, password)
  end

  # Set the Authorization header to include a given API token
  def set_api_token(token)
    @request.env['HTTP_AUTHORIZATION'] = "Token token=#{token}"
  end

  def json_response?(response)
    response["Content-Type"] == "application/json; charset=utf-8"
  end

  def roles
    [:account_holder, :administrator, :leader, :member]
  end
end

require "mocha/setup"
