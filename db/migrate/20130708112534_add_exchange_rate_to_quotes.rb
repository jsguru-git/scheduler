class AddExchangeRateToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :exchange_rate, :decimal, :precision => 10, :scale => 6
  end
end
