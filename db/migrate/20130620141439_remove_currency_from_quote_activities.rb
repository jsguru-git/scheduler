class RemoveCurrencyFromQuoteActivities < ActiveRecord::Migration
  def up
    remove_column :quotes, :currency
  end

  def down
    add_column :quotes, :currency, :string
  end
end
