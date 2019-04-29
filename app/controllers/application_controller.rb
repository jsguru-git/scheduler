class ApplicationController < ActionController::Base
  
  include Pundit
  # Callbacks
  before_filter :reload_libs if Rails.env.development?
  before_filter :load_breadcrumbs

  
  protect_from_forgery
  
  #
  # Dont allow ssl on non ssl pages
  def ensure_correct_protocol
    if request.ssl? #&& !ssl_allowed_action?
      redirect_options = {:protocol => 'http://', :status => :moved_permanently}
      if request.host
        redirect_options.merge!(:host => request.host)
      else
         redirect_options.merge!(:host => APP_CONFIG['env_config']['site_host'])
      end
      redirect_options.merge!(:params => request.query_parameters)
      redirect_to redirect_options
      #redirect_to "http://" + request.host + request.fullpath
    end
  end


protected


  # Reload lib files on each request in dev mode (needs to be done when they change)
  def reload_libs
    Dir["#{Rails.root}/lib/**/*.rb"].each { |path| require_dependency path }
  end

  def load_breadcrumbs
    @breadcrumbs = Breadcrumbs::Navigation.new
  end

end
