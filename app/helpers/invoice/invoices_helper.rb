module Invoice::InvoicesHelper
  
  
  # Used when showing a payment profile to display in the invoice currency
  def convert_to_invoice_currency(amount_cents, default_currnecy, invoice_currency)
    currency_cents = Currency.convert_amount(default_currnecy, invoice_currency, amount_cents)
    Money.new(currency_cents, invoice_currency).format(:no_cents_if_whole => false)
  end
  
  
end
