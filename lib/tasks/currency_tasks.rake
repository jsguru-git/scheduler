namespace :currency do


  # Get the lastest exchange rates
  task(:update_exchange_rates => :environment) do
    Currency.update_cached_rates
  end


end
