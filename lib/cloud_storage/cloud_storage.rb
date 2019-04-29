# Small library to provide a common interface, regardless of what file storage provider is being used. 
# Each provider should impliment the same set of functions and save / return data in the same way / format as each other.
require 'providers/cloud_storage_google'
require 'providers/cloud_storage_dropbox'

module CloudStorage
  class Base

    PROVIDERS = %w(dropbox google)

    # Create instance of the correct provider class
    def self.start(provider, current_user, perform_auth = true)
      provider = provider.to_s
      raise ArgumentError, CloudStorage::Base.exception_message(provider) unless PROVIDERS.include?(provider)
      if APP_CONFIG['oauth'].has_key?(provider)
        storage = "CloudStorage::" + provider.camelize + 'Provider'
        storage.constantize.new(current_user, perform_auth)
      end
    end

    def self.exception_message(provider)
      "#{ provider } is not a valid provider. Choose one of #{ CloudStorage::Base.provider_list_as_sentence }."
    end

    def self.provider_list_as_sentence
      PROVIDERS.to_sentence(last_word_connector: ' or ')
    end

  end
end
