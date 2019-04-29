require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# App Config
require 'yaml'

APP_CONFIG = YAML.load(File.open("config/settings/app_#{Rails.env}.yml"))
SELECTIONS = YAML.load(File.open("config/settings/selections.yml"))

secrets = { 'secrets' => YAML.load(File.open("config/secrets.yml")) }
APP_CONFIG.merge!(secrets)

env_config = { 'env_config' => YAML.load(File.open("config/dist/defaults.yml.config")) }
APP_CONFIG.merge!(env_config)

if Rails.env.development? || Rails.env.test?
    env_config = { 'env_config' => YAML.load(File.open("config/dist/dev.yml.config")) }
    APP_CONFIG.merge!(env_config)
else
    env_config = { 'env_config' => YAML.load(File.open("config/dist/#{ EY::Config.get(:base, :app_environment_name).split('/ ')[1].downcase }.yml.config")) }
    APP_CONFIG.merge!(env_config)
end

module Scheduling
    class Application < Rails::Application

        
        # Settings in config/environments/* take precedence over those specified here.
        # Application configuration should go into files in config/initializers
        # -- all .rb files in that directory are automatically loaded.

        # Custom directories with classes and modules you want to be autoloadable.
        # config.autoload_paths += %W(#{config.root}/extras)
        config.autoload_paths += %W(#{config.root}/lib)
        config.autoload_paths += %W(#{config.root}/lib/cloud_storage)

        # Only load the plugins named here, in the order given (default is alphabetical).
        # :all can be used as a placeholder for all plugins not explicitly named.
        # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

        # Activate observers that should always be running.
        # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

        # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
        # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
        config.time_zone = 'UTC'

        # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
        # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
        # config.i18n.default_locale = :de
        config.i18n.enforce_available_locales = true

        # Configure the default encoding used in templates for Ruby 1.9.
        config.encoding = "utf-8"

        # Configure sensitive parameters which will be filtered from the log file.
        config.filter_parameters += [:password]

        # Enable the asset pipeline
        config.assets.enabled = true

        # Version of your assets, change this if you want to expire all your assets
        config.assets.version = Date.today.to_time.to_i
        
        config.action_view.field_error_proc = Proc.new {|html_tag, instance|
            %(<span class="field_with_errors">#{html_tag}</span>).html_safe}
    end
end
