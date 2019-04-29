module CustomCurrencyHelper
  
  
  # Format an integer to a currency string using the accoutns defualt currency
  def formated_in_default_currency(amount_cents, no_cents_if_whole = false)
    Money.new(amount_cents, Money.default_currency).format(:no_cents_if_whole => no_cents_if_whole, :symbol => Money.default_currency.symbol)
  end
  
  
  # Format an integer to a currency string using the accoutns defualt currency
  def formated_in_provided_currency(amount_cents, currency_code, no_cents_if_whole = false)
    Money.new(amount_cents, currency_code).format(:no_cents_if_whole => no_cents_if_whole)
  end
  
  
end

