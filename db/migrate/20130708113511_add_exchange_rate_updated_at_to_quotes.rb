class AddExchangeRateUpdatedAtToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :exchange_rate_updated_at, :datetime
  end
end
