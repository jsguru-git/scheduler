class Api::V1::ApplicationController < ActionController::Base

  DEFAULT_START_DATE = 1.year.ago
  DEFAULT_END_DATE = Time.now

  before_filter :authenticate_user
  force_ssl

  protected

  def authenticate_user
    authenticate_or_request_with_http_token do |token, options|
      key = ApiKey.find_by_access_token(token)
      true if key && key.user.account.site_address == request.subdomain
    end
  end

end