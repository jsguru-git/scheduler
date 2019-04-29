class ChangeCurrencyExchangeRate < ActiveRecord::Migration
  def up
    execute("ALTER TABLE currencies CHANGE exchange_rate exchange_rate decimal(11, 6)")
  end

  def down
    execute("ALTER TABLE currencies CHANGE exchange_rate exchange_rate decimal(10, 6)")
  end
end
