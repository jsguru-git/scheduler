# A simple search class that wraps up openexchangerates.org
class OpenExchangeRates


    # External libs
    include HTTParty


    # Virtual attributes
    attr_reader :response


    # Httparty settings
    format :json
    base_uri 'http://openexchangerates.org'


    # Search defaults
    default_params({
      :app_id => APP_CONFIG['openexchangerates']['app_id']
    })


    # Get the latest exchange rates
    def get_latest_rates
      begin
        @response = self.class.get("/latest.json")
        return @response["rates"]
      rescue
        return {}
      end
    end

end
