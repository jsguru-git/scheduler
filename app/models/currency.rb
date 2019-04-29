class Currency < ActiveRecord::Base


  # External libs


  # Relationships


  # Validation
  validates :iso_code, :exchange_rate, :presence => true
  validates :exchange_rate, :numericality => {:only_integer => false, :allow_blank => true}
  validates_uniqueness_of :iso_code, :case_sensitive => false


  # Callbacks


  # Mass assignment protection
  attr_accessible


  # Plugins


  #
  # Extract functions
  #


  # Named scopes


  #
  # Save functions
  #


  # Get lastest exchange rates from api
  def self.update_cached_rates
    # Get latest rates
    open_exchange_rates = OpenExchangeRates.new
    unless Rails.env.test?
      new_rates = open_exchange_rates.get_latest_rates
    else
      new_rates = {}
    end

    # Update rates in database
    Currency.update_rates_in_db(new_rates)
  end


  #
  # Create functions
  #


  #
  # Update functions
  #


  #
  # General functions
  #


  # Get the exchange rate from one currency to another
  def self.get_exchange_for(from, to)
    return 1.0 if from.upcase == to.upcase
    
    from_currency = Currency.find_by_iso_code(from)
    to_currency = Currency.find_by_iso_code(to)
    # If currencies dont both exist return 0
    if from_currency.present? && to_currency.present?
      (to_currency.exchange_rate * (1.0 / from_currency.exchange_rate))
    else
      0
    end
  end
  
  
  # Convert amount from one currency to another
  def self.convert_amount(from_currency, to_currency, amount_cents, custom_exchange_rate = nil)
    if custom_exchange_rate.present?
      exchange_rate = custom_exchange_rate
    else
      exchange_rate = Currency.get_exchange_for(from_currency, to_currency)
    end
    # Check isn't 1 and therefor same currency
    return amount_cents if exchange_rate == 1.0
    
    Money.add_rate(from_currency, to_currency, exchange_rate)
    return Money.new(amount_cents, from_currency).exchange_to(to_currency).cents
  end
  

protected


  # Update rates in db
  def self.update_rates_in_db(new_rates)
    if new_rates.present? && new_rates.length > 0
      new_rates.each do |code, value|
        currency = Currency.exists?(:iso_code => code) ? Currency.find_by_iso_code(code) : Currency.new
        currency.iso_code = code
        currency.exchange_rate = value
        currency.save
      end
    end
  end


end
